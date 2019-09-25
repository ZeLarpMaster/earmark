defmodule Earmark.Helpers.HtmlParser do

  @moduledoc false

  import Earmark.Helpers.StringHelpers, only: [behead: 2]

  # Are leading and trailing "-"s ok?
  @tag_head ~r{\A\s*<([-\w]+)\s*}
  def parse_html(string) do
    case Regex.run(@tag_head, string) do
      [all, tag] -> parse_atts(behead(string, all), tag, [], string)
      _          -> parse_closing(string)
    end
  end

  @attribute ~r{\A([-\w]+)=(["'])(.*?)\2\s*}
  defp parse_atts(string, tag, atts, original) do
    case Regex.run(@attribute, string) do 
      [all, name, _delim, value] -> parse_atts(behead(string, all), tag, [{name, value}|atts], original)
      _                          -> parse_tag_tail(string, tag, atts, original)
    end
  end

  defp parse_tag_tail(string, tag, atts, original) do
    IO.inspect {3100, string}
    case Regex.run(~r{></#{tag}>\s*(.*)\z}, string) do
      [_, ""]      -> [{tag, Enum.reverse(atts)}] |> IO.inspect
      [_, garbage] -> [{tag, Enum.reverse(atts)}, garbage] |> IO.inspect
      _            -> parse_tag_tail_wo_closing(string, tag, atts, original) |> IO.inspect
    end
  end

  @tag_tail  ~r{\A/?>\s*(.*)\z}
  defp parse_tag_tail_wo_closing(string, tag, atts, original) do
    case Regex.run(@tag_tail, string) do
      [_, ""]      -> [{tag, Enum.reverse(atts)}]
      [_, garbage] -> [{tag, Enum.reverse(atts)}, garbage]
      _            -> [original]
    end
  end

  @closing_tag ~r{\A\s*</([^>]+)>\s*(.*)\z}
  defp parse_closing(string) do
    case Regex.run(@closing_tag, string) do
      [_all, tag, ""]      -> [{tag}]
      [_all, tag, garbage] -> [{tag}, garbage]
      _                    -> [string]
    end
  end
end
