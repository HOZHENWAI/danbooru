class MediaFile::Video < MediaFile
  extend Memoist

  def dimensions
    [video.width, video.height]
  end

  def preview(max_width, max_height)
    preview_frame.preview(max_width, max_height)
  end

  def crop(max_width, max_height)
    preview_frame.crop(max_width, max_height)
  end

  private

  def video
    FFMPEG::Movie.new(file.path)
  end

  def preview_frame
    vp = Tempfile.new(["video-preview", ".jpg"], binmode: true)
    video.screenshot(vp.path, seek_time: 0)
    MediaFile.open(vp.path)
  end

  memoize :video, :preview_frame
end