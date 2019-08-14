defmodule Earmark.Helpers.AstHelpers do

  import Earmark.Helpers
  import Earmark.Helpers.AttrParser

  alias Earmark.Block
  
  @simple_tag ~r{^<(.*?)\s*>}

  @doc false
  def augment_tag_with_ial(context, tag, ial, lnb) do 
    case Regex.run( @simple_tag, tag) do 
      nil ->
        nil
      ["<code class=\"inline\">", "code class=\"inline\""] ->
        tag = String.replace(tag, ~s{ class="inline"}, "")
        add_attrs(context, tag, ial, [{"class", ["inline"]}], lnb)
      _   ->
        add_attrs(context, tag, ial, [], lnb)
    end
  end

  @doc false
  def code_classes(language, prefix) do
    classes =
      ["" | String.split(prefix || "")]
      |> Enum.map(fn pfx -> "#{pfx}#{language}" end)
      {"class", classes |> Enum.join(" ")}
  end

  @doc false
  def codespan(text) do 
    { "code", [{"class", "inline"}], [text] }
  end

  @doc false
  def render_footnote_link(ref, backref, number) do
    {"a", [{"href", "##{ref}"}, {"id", backref}, {"class", "footnote"}, {"title", "see footnote"}], [number]}
  end

  @doc false
  def render_code(%Block.Code{lines: lines}) do
    lines |> Enum.join("\n")
  end


  @remove_escapes ~r{ \\ (?! \\ ) }x
  @doc false
  def render_image(text, href, title, lnb) do
    href = encode(href, false)
    IO.inspect {4305, href}
    alt = text |> escape() |> String.replace(@remove_escapes, "")
    IO.inspect {4310, alt}

    # context2 = _convert(text, lnb, set_value(context1, []), false)
    if title do
      { "img", [{"src", href}, {"alt", alt}, {"title", title}], [] }
    else
      { "img", [{"src", href}, {"alt", alt}], [] }
    end
  end

  @doc false
  def render_link(url, text), do: {"a", [{"href", url}], [text]}
  def render_link(url, text, nil), do: ~s[<a href="#{url}">#{text}</a>]
  def render_link(url, text, nil), do: {"a", [{"href", url}], [text]}
  def render_link(url, text, title), do: {"a", [{"href", url}, {"title", title}], [text]}


  ##############################################
  # add attributes to the outer tag in a block #
  ##############################################

  @doc false
  def add_attrs(atts, default \\ %{})
  def add_attrs(nil, default) do
    add_attrs(%{}, default)
  end
  def add_attrs(atts, default) do
#    IO.inspect {3000, atts, default}
    Map.merge(default, atts)
    |> Enum.map(fn {k, vs} -> {to_string(k), Enum.join(vs, " ")} end)
  end
  def add_attrs(context, text, attrs_as_string_or_map, default_attrs, lnb)
  def add_attrs(context, text, nil, [], _lnb), do: {context, text}
  def add_attrs(context, text, nil, default, lnb), do: add_attrs(context, text, %{}, default, lnb)
  def add_attrs(context, text, attrs, default, lnb) when is_binary(attrs) do
    {context1, attrs} = parse_attrs( context, attrs, lnb )
    add_attrs(context1, text, attrs, default, lnb)
  end
  def add_attrs(context, text, attrs, default, _lnb) do
    # IO.inspect {2000, attrs, default}
      default
      |> Map.new()
      |> Map.merge(attrs, fn _k, v1, v2 -> v1 ++ v2 end)
  end

  defp attrs_to_string(attrs) do
    (for { name, value } <- attrs, do: ~s/#{name}="#{Enum.join(value, " ")}"/)
                                                  |> Enum.join(" ")
  end

  defp add_to(attrs, text) do
    attrs = if attrs == "", do: "", else: " #{attrs}"
    String.replace(text, ~r{\s?/?>}, "#{attrs}\\0", global: false)
  end

end

# SPDX-License-Identifier: Apache-2.0
