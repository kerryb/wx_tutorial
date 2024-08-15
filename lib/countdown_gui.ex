defmodule CountdownGui do
  @moduledoc """
  A `GenServer` to display a countdown timer usin g wxWidgets
  """

  use GenServer

  import Bitwise
  import WX

  require Record

  defmodule State do
    @moduledoc false
    defstruct [:counter, :button, :counting_down?, :timer]
  end

  Record.defrecord(:wx, Record.extract(:wx, from_lib: "wx/include/wx.hrl"))
  Record.defrecord(:wxCommand, Record.extract(:wxCommand, from_lib: "wx/include/wx.hrl"))
  Record.defrecord(:wxClose, Record.extract(:wxClose, from_lib: "wx/include/wx.hrl"))

  def start_link(seconds, options \\ []) when is_integer(seconds) do
    GenServer.start_link(__MODULE__, seconds, options)
  end

  @impl GenServer
  def init(seconds) do
    :wx.new()
    frame = :wxFrame.new(:wx.null(), wxID_ANY(), "Countdown")

    label = :wxStaticText.new(frame, wxID_ANY(), "Seconds remaining", style: wxTE_RIGHT())
    :wxStaticText.wrap(label, 100)

    counter =
      :wxTextCtrl.new(frame, wxID_ANY(), value: Integer.to_charlist(seconds), style: wxALIGN_RIGHT())

    font = :wxFont.new(42, wxFONTFAMILY_DEFAULT(), wxFONTSTYLE_NORMAL(), wxFONTWEIGHT_BOLD())
    :wxTextCtrl.setFont(counter, font)

    button =
      :wxButton.new(frame, wxID_ANY(), label: "Start", pos: {0, 64}, style: wxBU_LEFT())

    counter_sizer = :wxBoxSizer.new(wxHORIZONTAL())
    :wxSizer.add(counter_sizer, label, flag: wxALL() ||| wxALIGN_CENTRE(), border: 5)
    :wxSizer.add(counter_sizer, counter, flag: wxALL() ||| wxEXPAND(), border: 5, proportion: 1)

    main_sizer = :wxBoxSizer.new(wxVERTICAL())
    :wxSizer.add(main_sizer, counter_sizer, flag: wxALL() ||| wxEXPAND())
    :wxSizer.add(main_sizer, button, flag: wxALL() ||| wxEXPAND(), border: 5)
    :wxWindow.setSizer(frame, main_sizer)
    :wxSizer.setSizeHints(main_sizer, frame)
    :wxWindow.setMinSize(frame, :wxWindow.getSize(frame))

    :wxButton.connect(button, :command_button_clicked, userData: %{counter: counter, env: :wx.get_env()})
    :wxFrame.connect(frame, :close_window)

    :wxFrame.show(frame)
    {:ok, %State{counter: counter, button: button, counting_down?: false}}
  end

  @impl GenServer
  def handle_info(wx(event: wxCommand(type: :command_button_clicked)), %{counting_down?: false} = state) do
    if List.to_integer(:wxTextCtrl.getValue(state.counter)) == 0 do
      {:noreply, state}
    else
      :wxTextCtrl.setEditable(state.counter, false)
      :wxButton.setLabel(state.button, ~c"Stop")
      timer = Process.send_after(self(), :update_gui, :timer.seconds(1))
      {:noreply, %{state | counting_down?: true, timer: timer}}
    end
  end

  def handle_info(wx(event: wxCommand(type: :command_button_clicked)), state) do
    Process.cancel_timer(state.timer)
    :wxTextCtrl.setEditable(state.counter, true)
    :wxButton.setLabel(state.button, ~c"Start")
    {:noreply, %{state | counting_down?: false, timer: nil}}
  end

  def handle_info(wx(event: wxClose(type: :close_window)), state) do
    {:stop, :normal, state}
  end

  def handle_info(:update_gui, state) do
    case List.to_integer(:wxTextCtrl.getValue(state.counter)) do
      1 ->
        :wxTextCtrl.setValue(state.counter, ~c"0")
        :wxTextCtrl.setEditable(state.counter, true)
        :wxButton.setLabel(state.button, ~c"Start")
        {:noreply, %{state | counting_down?: false}}

      n ->
        :wxTextCtrl.setValue(state.counter, Integer.to_charlist(n - 1))
        timer = Process.send_after(self(), :update_gui, :timer.seconds(1))
        {:noreply, %{state | timer: timer}}
    end
  end
end
