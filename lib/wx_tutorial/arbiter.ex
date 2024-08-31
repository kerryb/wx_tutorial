defmodule WxTutorial.Arbiter do
  @moduledoc false
  use WxObject

  import WxEx.Constants
  import WxEx.Records

  alias WxTutorial.Player

  def start_link(_arg) do
    wx_ref() = ref = WxObject.start_link(__MODULE__, nil, name: __MODULE__)
    {:ok, WxObject.get_pid(ref)}
  end

  def moved(player), do: WxObject.cast(__MODULE__, {:moved, player})

  def i_lose(player), do: WxObject.cast(__MODULE__, {:i_lose, player})

  @impl WxObject
  def init(_arg) do
    :wx.new()

    frame = :wxFrame.new(:wx.null(), 1, "Countdown")
    player_1 = Player.start_link(:player_1, frame, __MODULE__)
    player_2 = Player.start_link(:player_2, frame, __MODULE__)

    main_sizer = :wxBoxSizer.new(wxHORIZONTAL())
    :wxSizer.add(main_sizer, player_1, proportion: 1, flag: wxALL(), border: 5)
    :wxSizer.add(main_sizer, player_2, proportion: 1, flag: wxALL(), border: 5)
    :wxWindow.setSizer(frame, main_sizer)
    :wxSizer.setSizeHints(main_sizer, frame)
    :wxWindow.setMinSize(frame, :wxWindow.getSize(frame))

    :wxFrame.connect(frame, :close_window)
    :wxFrame.show(frame)

    Player.move(:player_1)
    {frame, nil}
  end

  @impl WxObject
  def handle_cast({:moved, :player_1}, state) do
    Player.move(:player_2)
    {:noreply, state}
  end

  def handle_cast({:moved, :player_2}, state) do
    Player.move(:player_1)
    {:noreply, state}
  end

  def handle_cast({:i_lose, :player_1}, state) do
    Player.you_win(:player_2)
    {:noreply, state}
  end

  def handle_cast({:i_lose, :player_2}, state) do
    Player.you_win(:player_1)
    {:noreply, state}
  end

  @impl WxObject
  def handle_info({:reset, seconds}, state) do
    Player.reset(:player_1, seconds)
    Player.reset(:player_2, seconds)
    {:noreply, state}
  end

  @impl WxObject
  def handle_event(wx(event: wxClose()), state) do
    {:stop, :normal, state}
  end

  @impl WxObject
  def terminate(reason, _state) do
    WxObject.stop(:player_1, reason)
    WxObject.stop(:player_2, reason)
    :wx.destroy()
    :ok
  end
end
