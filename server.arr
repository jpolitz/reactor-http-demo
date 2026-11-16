use context starter2024
import http as HTTP

colors = [list: "red", "orange", "green", "blue", "purple"]

init-state = {url: "starting...", hits: 0, votes: colors.map(lam(_): 0 end), recent: empty}

fun bump(votes, color):
  map2(lam(c, v): if c == color: v + 1 else: v end end, colors, votes)
end

fun remember(s, req):
  entry = req.http-method + " " + req.path
  s.{hits: s.hits + 1, recent: link(entry, s.recent).take(num-min(8, s.recent.length() + 1))}
end

fun page(s):
  rows = map2(
    lam(c, v):
      "<li><a href='/vote/" + c + "'>" + c + "</a> " + num-to-string(v) + "</li>"
    end,
    colors, s.votes)
  "<!doctype html><title>Pyret reactor</title><h1>Served by a Pyret reactor</h1>"
    + "<p>" + num-to-string(s.hits) + " requests so far. Vote:</p>"
    + "<ul>" + rows.join-str("") + "</ul>"
end

fun handle(s, req):
  s1 = remember(s, req)
  parts = string-split-all(req.path, "/")
  ask:
    | req.path == "/" then: {s1; HTTP.html(req, page(s1))}
    | (parts.length() == 3) and (parts.get(1) == "vote") and colors.member(parts.get(2)) then:
      s2 = s1.{votes: bump(s1.votes, parts.get(2))}
      {s2; HTTP.html(req, page(s2))}
    | otherwise: {s1; HTTP.response(req, 404, "text/plain", "Nothing at " + req.path + "\n")}
  end
end

fun bar(color, votes):
  above(
    rectangle(50, 4 + (votes * 16), "solid", color),
    text(num-to-string(votes), 18, "black"))
end

fun draw(s):
  bars = fold(
    lam(acc, img): beside-align("bottom", acc, beside(square(10, "solid", "white"), img)) end,
    empty-image,
    map2(bar, colors, s.votes))
  log = fold(
    lam(acc, entry): above-align("left", acc, text(entry, 14, "dimgray")) end,
    empty-image,
    s.recent)
  content = above-align("left",
    text(s.url, 16, "navy"),
    above-align("left",
      text(num-to-string(s.hits) + " requests", 24, "black"),
      above-align("left", bars, log)))
  overlay-align("left", "top", content, rectangle(520, 420, "solid", "white"))
end

r = reactor:
  init: init-state,
  on(HTTP.started): lam(s, url): s.{url: url} end,
  on-to(HTTP.request, HTTP.respond): handle,
  to-draw: draw
end

r.interact()
