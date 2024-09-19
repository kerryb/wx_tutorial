defmodule WxTutorial.Player do
  @moduledoc false
  use WxObject
  use WxEx

  import Bitwise

  alias WxTutorial.Arbiter

  defmodule State do
    @moduledoc false
    defstruct [:panel, :counter, :button, :timer, :who_am_i, :arbiter]
  end

  def start_link(name, frame, arbiter) do
    WxObject.start_link(name, __MODULE__, [name, frame, arbiter])
  end

  def get_panel(player), do: WxObject.call(player, :get_panel)

  def reset(player, seconds), do: WxObject.cast(player, {:reset, seconds})

  def move(player), do: WxObject.cast(player, :move)

  def you_win(player), do: WxObject.cast(player, :you_win)

  @impl WxObject
  def init([name, frame, arbiter]) do
    panel = :wxPanel.new(frame)

    label = :wxStaticText.new(panel, wxID_ANY(), "Seconds remaining", style: wxALIGN_RIGHT())
    :wxStaticText.wrap(label, 100)

    counter =
      :wxTextCtrl.new(panel, wxID_ANY(), value: ~c"42", style: wxTE_RIGHT())

    font = :wxFont.new(42, wxFONTFAMILY_DEFAULT(), wxFONTSTYLE_NORMAL(), wxFONTWEIGHT_BOLD())
    :wxTextCtrl.setFont(counter, font)

    button = :wxButton.new(panel, wxID_ANY(), label: "Moved")
    :wxButton.disable(button)

    counter_sizer = :wxBoxSizer.new(wxHORIZONTAL())
    :wxSizer.add(counter_sizer, label, flag: wxALL() ||| wxALIGN_CENTRE(), border: 5)
    :wxSizer.add(counter_sizer, counter, flag: wxALL() ||| wxEXPAND(), border: 5, proportion: 1)

    main_sizer = :wxBoxSizer.new(wxVERTICAL())
    :wxSizer.add(main_sizer, counter_sizer, flag: wxEXPAND())
    :wxSizer.add(main_sizer, button, flag: wxALL() ||| wxEXPAND(), border: 5)

    :wxWindow.setSizer(panel, main_sizer)
    :wxSizer.setSizeHints(main_sizer, panel)
    :wxWindow.setMinSize(panel, :wxWindow.getSize(panel))

    :wxButton.connect(button, :command_button_clicked)

    {panel, %State{panel: panel, counter: counter, button: button, who_am_i: name, arbiter: arbiter}}
  end

  @impl WxObject
  def handle_call(:get_panel, _from, state) do
    {:reply, state.panel, state}
  end

  @impl WxObject
  def handle_cast(:move, state) do
    :wxButton.enable(state.button)
    timer = Process.send_after(self(), :update_gui, :timer.seconds(1))
    {:noreply, %{state | timer: timer}}
  end

  def handle_cast(:you_win, state) do
    :wxTextCtrl.setValue(state.counter, ~c"win")
    {:noreply, state}
  end

  @impl WxObject
  def handle_event(wx(event: wxCommand(type: :command_button_clicked)), state) do
    Process.cancel_timer(state.timer)
    :wxButton.disable(state.button)
    Arbiter.moved(state.who_am_i)
    {:noreply, %{state | timer: nil}}
  end

  @impl WxObject
  def handle_info(:update_gui, state) do
    case List.to_integer(:wxTextCtrl.getValue(state.counter)) do
      1 ->
        :wxTextCtrl.setValue(state.counter, ~c"0")
        :wxButton.disable(state.button)
        Arbiter.i_lose(state.who_am_i)
        {:noreply, state}

      seconds ->
        :wxTextCtrl.setValue(state.counter, Integer.to_charlist(seconds - 1))
        timer = Process.send_after(self(), :update_gui, :timer.seconds(1))
        {:noreply, %{state | timer: timer}}
    end
  end
end
