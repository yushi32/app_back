class Bookmark < ApplicationRecord
  require 'metainspector'

  validates :url, presence: true, uniqueness: { scope: :user_id }
  validates :title, presence: true
  validates :status, presence: true
  validates :note, length: { maximum: 500 }

  belongs_to :user
  belongs_to :folder, optional: true
  has_many :bookmark_tags, -> { order(created_at: :asc) }, dependent: :destroy
  has_many :tags, through: :bookmark_tags

  enum status: { unnotified: 0, notified: 1, read: 2 }

  scope :for_notification, lambda {
    unnotified_ids = unnotified.pluck(:id)
    selected_ids = unnotified_ids.sample(3)
    where(id: selected_ids).order(id: :asc)
  }

  def generate_tag_from_url
    target_domain = URI.parse(url).host
    same_domain_count = user.bookmarks.where('url LIKE ?', "%#{target_domain}%").count
    return nil if same_domain_count < 2

    # 取得したタイトルを仕切り文字で分割して、最初の非空文字列をタグ名とする
    delimiters = [' ', '|', ':', '/', '-', 'ー', '　', '｜', '：', '／', '－']
    delimiter_pattern = Regexp.union(delimiters.map { |delimiter| Regexp.escape(delimiter) })

    max_retries = 3
    begin
      retries ||= 0
      page = MetaInspector.new("https://#{target_domain}")
      page.title.split(delimiter_pattern).reject(&:empty?).first
    rescue Net::OpenTimeout, Net::ReadTimeout, MetaInspector::Error
      retries += 1
      retry if retries < max_retries
      nil
    rescue URI::InvalidURIError
      nil
    end
  end

  def save_with_tags(tag_names, current_user)
    ActiveRecord::Base.transaction do
      # tag_namesが空の場合、関連付けられているすべてのタグを削除する
      if tag_names.blank?
        tags.clear if tags.present?
      else
        # 更新前のタグと差分を特定
        current_tags = tags.pluck(:name)
        tags_to_remove = current_tags - tag_names

        # 未登録のタグを追加する
        add_new_tags(tag_names, current_user)

        # タグの削除処理
        if tags_to_remove.present?
          tags_to_remove.each do |tag_name|
            tag_to_remove = Tag.find_by(name: tag_name)
            tags.delete(tag_to_remove)
          end
        end
      end
      save!
    end
    true
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique::Error => e
    Rails.logger.error("An error occurred when creating a new Bookmark record: #{e.class} - #{e.message}")
    false
  rescue StandardError => e
    Rails.logger.error("An error occurred when creating a new Bookmark record: #{e.class} - #{e.message}")
    false
  end

  private

  def add_new_tags(tag_names, current_user)
    tag_names.each do |tag_name|
      new_tag = Tag.find_or_create_by(name: tag_name)
      add_tag(new_tag) unless tagged?(new_tag.id)

      current_user.add_tag(new_tag) unless current_user.tag_used?(new_tag.id)
    end
  end

  def add_tag(tag)
    tags << tag
  end

  def tagged?(tag_id)
    tags.exists?(id: tag_id)
  end
end
