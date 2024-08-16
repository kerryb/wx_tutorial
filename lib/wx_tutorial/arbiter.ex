defmodule WxTutorial.Arbiter do
  @moduledoc false
  use GenServer

  import WX

  alias WxTutorial.Player

  require Record

  Record.defrecord(:wx, Record.extract(:wx, from_lib: "wx/include/wx.hrl"))
  Record.defrecord(:wxClose, Record.extract(:wxClose, from_lib: "wx/include/wx.hrl"))

  def start_link(_arg), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  def moved(player), do: GenServer.cast(__MODULE__, {:moved, player})

  def i_lose(player), do: GenServer.cast(__MODULE__, {:i_lose, player})

  @impl GenServer
  def init(_arg) do
    :wx.new()
    env = :wx.get_env()

    frame = :wxFrame.new(:wx.null(), 1, "Countdown")
    {:ok, _} = Player.start_link(:player_1, env, frame, __MODULE__)
    {:ok, _} = Player.start_link(:player_2, env, frame, __MODULE__)
    player_1 = Player.get_panel(:player_1)
    player_2 = Player.get_panel(:player_2)

    main_sizer = :wxBoxSizer.new(wxHORIZONTAL())
    :wxSizer.add(main_sizer, player_1, proportion: 1, flag: wxALL(), border: 5)
    :wxSizer.add(main_sizer, player_2, proportion: 1, flag: wxALL(), border: 5)
    :wxWindow.setSizer(frame, main_sizer)
    :wxSizer.setSizeHints(main_sizer, frame)
    :wxWindow.setMinSize(frame, :wxWindow.getSize(frame))

    :wxFrame.connect(frame, :close_window)
    :wxFrame.show(frame)

    Player.move(:player_1)
    {:ok, nil}
  end

  @impl GenServer
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

  @impl GenServer
  def handle_info({:reset, seconds}, state) do
    Player.reset(:player_1, seconds)
    Player.reset(:player_2, seconds)
    {:noreply, state}
  end

  def handle_info(wx(event: wxClose()), state) do
    {:stop, :normal, state}
  end

  @impl GenServer
  def terminate(reason, _state) do
    GenServer.stop(:player_1, reason)
    GenServer.stop(:player_2, reason)
    :wx.destroy()
    :ok
  end
end
