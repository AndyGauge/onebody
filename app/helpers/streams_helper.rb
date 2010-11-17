module StreamsHelper
  include MessagesHelper

  def stream_item_path(stream_item)
    send(stream_item.streamable_type.underscore + '_path', stream_item.streamable_id)
  end

  def stream_item_url(stream_item)
    send(stream_item.streamable_type.underscore + '_url', stream_item.streamable_id)
  end

  def stream_item_content(stream_item, use_code=false)
    if stream_item.body
      content = if stream_item.streamable_type == 'Message'
        render_message_body(stream_item)
      else
        sanitize_html(auto_link(stream_item.body))
      end
    elsif stream_item.context.any?
      content = ''.tap do |content|
        stream_item.context['picture_ids'].to_a.each do |picture_id, fingerprint, extension|
          content << link_to(
            image_tag(Picture.photo_url_from_parts(picture_id, fingerprint, extension, :small), :alt => t('pictures.click_to_enlarge'), :class => 'stream-pic'),
            album_picture_path(stream_item.streamable_id, picture_id), :title => t('pictures.click_to_enlarge')
          ) + ' '
        end
      end.html_safe
    end
    if use_code
      content.gsub!(/<img([^>]+)src="(.+?)"/) do |match|
        url = $2 + ($2.include?('?') ? '&' : '?') + 'code=' + @logged_in.feed_code
        "<img#{$1}src=\"#{url}\""
      end
    end
    content
  end

  def recent_time_ago_in_words(time)
    if time >= 1.day.ago
      time_ago_in_words(time) + ' ' + t('stream.ago')
    else
      time.to_s
    end
  end

  def stream_type_checkmark(name, type, checked_by_default=true)
    enabled = cookies["stream_#{type}"]
    enabled = cookies["stream_#{type}"] = checked_by_default if cookies["stream_#{type}"].nil?
    link_to_function(
      image_tag(enabled ? 'checkmark.png' : 'remove.gif', :alt => t('stream.enable_disable') + " #{name}", :class => 'icon') + " #{name}",
      "enable_stream_item_type('" + type + "', this.getElementsByTagName('img')[0].readAttribute('src') != '/images/checkmark.png');",
      :id => "enable-stream_" + type
    )
  end


end
