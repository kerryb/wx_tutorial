defmodule CountdownGui do
  def start(seconds) when is_integer(seconds) do
    :wx.new()
    frame = :wxFrame.new(:wx.null(), WX.wxID_ANY(), "Countdown")
    counter = :wxStaticText.new(frame, WX.wxID_ANY(), Integer.to_charlist(seconds))
    :wxFrame.show(frame)
    countdown(seconds - 1, counter)
    :timer.sleep(:timer.seconds(10))
  end

  def countdown(seconds, _counter) when seconds < 0 do
    :ok
  end

  def countdown(seconds, counter) do
    :timer.sleep(:timer.seconds(1))
    :wxStaticText.setLabel(counter, Integer.to_charlist(seconds))
    countdown(seconds - 1, counter)
  end
end
