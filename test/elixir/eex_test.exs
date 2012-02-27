Code.require_file "../test_helper", __FILE__

defmodule EExTest do
  use ExUnit::Case

  test "compile simple string" do
    assert_eval "foo bar", "foo bar"
  end

  test "compile with embedded" do
    assert_eval "foo bar", "foo <%= :bar %>"
  end

  test "compile with embedded do end" do
    assert_eval "foo bar", "foo <% if true do %>bar<% end %>"
  end

  test "compile with embedded do end and eval the expression" do
    assert_eval "foo ", "foo <% if false do %>bar<% end %>"
  end

  test "compile with embedded do end and nested print expression" do
    assert_eval "foo bar", "foo <% if true do %><%= :bar %><% end %>"
  end

  test "compile with embedded do end and nested expressions" do
    assert_eval "foo bar baz", "foo <% if true do %>bar <% Process.put(:eex_text, 1) %><%= :baz %><% end %>"
    assert_equal 1, Process.get(:eex_text)
  end

  test "compile with embedded middle expression" do
    assert_eval "foo bar", "foo <% if true do %>bar<% else: %>baz<% end %>"
  end

  test "compile with embedded middle expression and eval the expression" do
    assert_eval "foo baz", "foo <% if false do %>bar<% else: %>baz<% end %>"
  end

  test "compile with nested start expression" do
    assert_eval "foo bar", "foo <% if true do %><% if true do %>bar<% end %><% end %>"
  end

  test "compile with nested middle expression" do
    assert_eval "foo baz", "foo <% if true do %><% if false do %>bar<% else: %>baz<% end %><% end %>"
  end

  test "compile with defined variable" do
    assert_eval "foo 1", "foo <% bar = 1 %><%= bar %>"
  end

  test "compile with require code" do
    assert_eval "foo 1,2,3", "foo <% require Enum, as: E %><%= E.join [1,2,3], \",\" %>"
  end

  defp assert_eval(expected, atual) do
    compiled = EEx.compile(atual)
    { result, _ } = Code.eval_quoted(compiled, [], __FILE__, __LINE__)
    assert_equal expected, result
  end
end
