# Basic implementation of Finite Automatons
#
# An Automaton is defined as:
# M = (Q, \Sigma, \delta, F, q_0)
#Enrique Martinez de Velasco Reyna 
# 2024-04-26


defmodule TokenList do
  def arithmetic_lexer(string) do
    automata = {&delta_arithmetic/2, [:var, :oper, :int, :float, :exp, :space, :paren_open, :paren_close, :comment], :start}
    string
    |> String.graphemes()
    |> eval_dfa(automata, [])
  end

  def eval_dfa([], {_delta, accept, state}, tokens) do
    if Enum.member?(accept, state) do
      {:ok, Enum.reverse(tokens)}
    else
      {:error, "Invalid input"}
    end
  end

  def eval_dfa([], _state, _input, _tokens), do: {:error, "Invalid input"}

  def eval_dfa([char | tail], {delta, accept, state}, input, tokens) do
    [new_state, found] = delta.(state, char)
    cond do
      found -> eval_dfa(tail, {delta, accept, new_state}, [char | input], [{found, Enum.reverse(input)} | tokens])
      true -> eval_dfa(tail, {delta, accept, new_state}, [char | input], tokens)
    end
  end

  def delta_arithmetic(:start, "/") do
    {:comment_start, false}
  end

  def delta_arithmetic(:comment_start, "/") do
    {:comment_line, false}
  end

  def delta_arithmetic(:comment_line, "\n"), do: {:start, :comment}
  def delta_arithmetic(_, "\n"), do: {:start, :comment}

  def delta_arithmetic(state, char) do
    case state do
      :start -> cond do
        is_sign(char) -> [:sign, false]
        is_digit(char) -> [:int, false]
        is_alapha(char) -> [:var, false]
        char == "(" -> [:paren_open, false]
        char == ")" -> [:paren_close, false]
        char == " " -> [:space, false]
        true -> [:fail, false]
      end
      :var -> cond do
        is_alapha(char) -> [:var, false]
        is_digit(char) -> [:var, false] # Allow digits in variable names
        true -> [:fail, false]
      end
      :int -> cond do
        is_digit(char) -> [:int, false]
        is_operator(char) -> [:oper, :int]
        char == "." -> [:dot, false]
        true -> [:fail, false]
      end
      :dot -> cond do
        is_digit(char) -> [:float, false]
        true -> [:fail, false]
      end
      :float -> cond do
        is_digit(char) -> [:float, false]
        is_operator(char) -> [:oper, :float]
        char == "e" -> [:exp, false]
        true -> [:fail, false]
      end
      :exp -> cond do
        is_sign(char) -> [:sign, false]
        is_digit(char) -> [:exp, false]
        true -> [:fail, false]
      end
      :oper -> cond do
        is_sign(char) -> [:sign, false]
        is_digit(char) -> [:int, false]
        true -> [:fail, false]
      end
      :sign -> cond do
        is_digit(char) -> [:int, false]
        true -> [:fail, false]
      end
      :paren_open -> cond do
        true -> [:fail, false]
      end
      :paren_close -> cond do
        true -> [:fail, false]
      end
      :space -> cond do
        true -> [:fail, false]
      end
      :comment_start -> cond do
        true -> [:fail, false]
      end
      :comment_line -> cond do
        true -> [:fail, false]
      end
      :fail -> [:fail, false]
    end
  end

  def is_digit(char) do
    "0123456789"
    |> String.graphemes()
    |> Enum.member?(char)
  end

  def is_alapha(char) do
    lowercase = ?a..?z |> Enum.map(&<<&1::utf8>>)
    uppercase = ?A..?Z |> Enum.map(&<<&1::utf8>>)
    Enum.member?(lowercase ++ uppercase, char)
  end

  def is_sign(char) do
    Enum.member?(["+", "-"], char)
  end

  def is_operator(char) do
    Enum.member?(["+", "-", "*", "/", "%", "^", "="], char)
  end
end
