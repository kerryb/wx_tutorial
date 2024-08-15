defmodule WX do
  @moduledoc """
  Just the values from `wx.hrl` that are used in this project.
  """

  import Bitwise

  def wxID_ANY, do: -1
  def wxLEFT, do: 16
  def wxRIGHT, do: 32
  def wxUP, do: 64
  def wxDOWN, do: 128
  def wxALL, do: wxUP() ||| wxDOWN() ||| wxRIGHT() ||| wxLEFT()
  def wxVERTICAL, do: 8
  def wxHORIZONTAL, do: 4
  def wxALIGN_RIGHT, do: 512
  def wxALIGN_CENTER_HORIZONTAL, do: 256
  def wxALIGN_CENTER_VERTICAL, do: 2048
  def wxALIGN_CENTRE, do: wxALIGN_CENTER_HORIZONTAL() ||| wxALIGN_CENTER_VERTICAL()
  def wxTE_RIGHT, do: wxALIGN_RIGHT()
  def wxBU_LEFT, do: 64
  def wxEXPAND, do: 8192
  def wxFONTFAMILY_DEFAULT, do: 70
  def wxFONTSTYLE_NORMAL, do: 90
  def wxFONTWEIGHT_BOLD, do: 92
end
