defmodule Short.Shortening.ShortUrlTest do
  use Short.DataCase

  alias Short.Shortening.ShortUrl

  describe "short_urls" do
    test "a valid url" do
      changeset = ShortUrl.insert_changeset(%{url: "http://crouton.net"})
      assert changeset.valid?
      assert String.length(changeset.changes[:slug]) == 8
    end

    test "an invalid url" do
      changeset = ShortUrl.insert_changeset(%{url: 5})
      refute changeset.valid?
      [url: {"is invalid", _}] = changeset.errors
    end
  end
end
