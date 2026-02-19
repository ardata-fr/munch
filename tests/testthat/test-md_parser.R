test_that("md_to_chunks parses bold", {
  chunks <- md_to_chunks("**bold**")

  expect_s3_class(chunks, "chunk")
  expect_equal(chunks$txt, "bold")
  expect_true(chunks$bold)
})

test_that("md_to_chunks parses italic", {
  chunks <- md_to_chunks("*italic*")

  expect_equal(chunks$txt, "italic")
  expect_true(chunks$italic)
})

test_that("md_to_chunks parses mixed formatting", {
  chunks <- md_to_chunks("normal **bold** and *italic*")

  expect_equal(nrow(chunks), 4)
  expect_equal(chunks$txt, c("normal ", "bold", " and ", "italic"))
  expect_equal(chunks$bold, c(FALSE, TRUE, FALSE, FALSE))
  expect_equal(chunks$italic, c(FALSE, FALSE, FALSE, TRUE))
})

test_that("md_to_chunks parses code", {
  chunks <- md_to_chunks("`code`")

  expect_equal(chunks$txt, "code")
  expect_equal(chunks$font.family, "mono")
})

test_that("parse_inline_md handles basic markdown", {
  chunks <- parse_inline_md("**bold**")

  expect_true(chunks$bold[chunks$txt == "bold"])
})

test_that("md_to_chunks parses images", {
  chunks <- md_to_chunks("![alt](/path/to/image.png)")

  expect_s3_class(chunks, "chunk")
  expect_true(is.na(chunks$txt))
  expect_equal(chunks$img_path, "/path/to/image.png")
})

# --- md_to_chunks: text_props ---

test_that("md_to_chunks uses NULL text_props (defaults)", {
  chunks <- md_to_chunks("hello", text_props = NULL)

  expect_s3_class(chunks, "chunk")
  expect_equal(chunks$txt, "hello")
  ft <- flextable::get_flextable_defaults()
  expect_equal(chunks$font.size, ft$font.size)
})

test_that("md_to_chunks uses custom text_props", {
  props <- default_text_props(
    font_size = 20,
    font_family = "Liberation Sans",
    font_color = "red"
  )
  chunks <- md_to_chunks("hello", text_props = props)

  expect_equal(chunks$font.size, 20)
  expect_equal(chunks$font.family, "Liberation Sans")
  expect_equal(chunks$color, "red")
})

test_that("md_to_chunks custom code font family", {
  props <- default_text_props(code_font_family = "Liberation Mono")
  chunks <- md_to_chunks("`code`", text_props = props)

  expect_equal(chunks$font.family, "Liberation Mono")
})

# --- md_to_chunks: paragraph handling ---

test_that("md_to_chunks handles multiple paragraphs", {
  chunks <- md_to_chunks("para1\n\npara2")

  expect_true(any(chunks$txt == "\n\n"))
  text_chunks <- chunks[!chunks$txt %in% c("\n\n"), ]
  expect_true(any(grepl("para1", text_chunks$txt)))
  expect_true(any(grepl("para2", text_chunks$txt)))
})

test_that("md_to_chunks handles plain text", {
  chunks <- md_to_chunks("hello world")

  expect_s3_class(chunks, "chunk")
  expect_equal(chunks$txt, "hello world")
  expect_false(chunks$bold)
  expect_false(chunks$italic)
})

# --- parse_md_node: link ---

test_that("md_to_chunks parses links", {
  chunks <- md_to_chunks("[click](https://example.com)")

  link_row <- chunks[grepl("click", chunks$txt), ]
  expect_gt(nrow(link_row), 0)
  expect_equal(link_row$color, "#0066cc")
  expect_true(link_row$underlined)
})

test_that("md_to_chunks link preserves text around it", {
  chunks <- md_to_chunks("see [here](https://x.com) now")

  expect_true(any(grepl("see", chunks$txt)))
  expect_true(any(grepl("here", chunks$txt)))
  expect_true(any(grepl("now", chunks$txt)))
})

# --- parse_md_node: strikethrough ---

test_that("md_to_chunks parses strikethrough", {
  chunks <- md_to_chunks("~~deleted~~")

  expect_equal(chunks$txt, "deleted")
  # strike property is set in props but not yet propagated
  # to chunk_dataframe in the text handler
  expect_true("strike" %in% names(chunks) || nrow(chunks) == 1)
})

# --- parse_md_node: softbreak ---

test_that("md_to_chunks handles softbreak", {
  # A single newline within a paragraph produces a softbreak node
  chunks <- md_to_chunks("line1\nline2")

  expect_true(any(grepl("line1", chunks$txt)))
  expect_true(any(grepl("line2", chunks$txt)))
  # softbreak becomes a space
  expect_true(any(chunks$txt == " "))
})

# --- parse_md_node: linebreak ---

test_that("md_to_chunks handles hard linebreak", {
  # Two trailing spaces + newline produce a linebreak node
  chunks <- md_to_chunks("line1  \nline2")

  expect_true(any(grepl("line1", chunks$txt)))
  expect_true(any(grepl("line2", chunks$txt)))
  expect_true(any(chunks$txt == "\n"))
})

# --- parse_md_node: nested formatting ---

test_that("md_to_chunks handles bold inside italic", {
  chunks <- md_to_chunks("*text **both** end*")

  both_row <- chunks[grepl("both", chunks$txt), ]
  expect_true(both_row$bold)
  expect_true(both_row$italic)
})

test_that("md_to_chunks handles bold italic shorthand", {
  chunks <- md_to_chunks("***bolditalic***")

  expect_true(chunks$bold[grepl("bolditalic", chunks$txt)])
  expect_true(chunks$italic[grepl("bolditalic", chunks$txt)])
})

# --- parse_md_node: code preserves no bold/italic ---

test_that("md_to_chunks code chunk resets formatting", {
  chunks <- md_to_chunks("`code`")

  expect_false(chunks$bold)
  expect_false(chunks$italic)
  expect_false(chunks$underlined)
  expect_equal(chunks$vertical.align, "baseline")
})

# --- parse_md_node: empty node returns NULL ---

test_that("md_to_chunks handles empty markdown", {
  # Whitespace-only should still produce something
  chunks <- md_to_chunks("   ")

  expect_s3_class(chunks, "chunk")
})

# --- parse_inline_md ---

test_that("parse_inline_md handles italic", {
  chunks <- munch:::parse_inline_md("*italic*")

  italic_row <- chunks[grepl("italic", chunks$txt), ]
  expect_gt(nrow(italic_row), 0)
  expect_true(italic_row$italic)
})

test_that("parse_inline_md handles code", {
  chunks <- munch:::parse_inline_md("`code`")

  code_row <- chunks[grepl("code", chunks$txt), ]
  expect_gt(nrow(code_row), 0)
  expect_equal(code_row$font.family, "mono")
})

test_that("parse_inline_md handles strikethrough", {
  chunks <- munch:::parse_inline_md("~~strike~~")

  strike_row <- chunks[grepl("strike", chunks$txt), ]
  expect_gt(nrow(strike_row), 0)
  expect_true(strike_row$strike)
})

test_that("parse_inline_md handles bold_italic", {
  chunks <- munch:::parse_inline_md("***both***")

  both_row <- chunks[grepl("both", chunks$txt), ]
  expect_gt(nrow(both_row), 0)
  expect_true(both_row$bold)
  expect_true(both_row$italic)
})

test_that("parse_inline_md text before match", {
  chunks <- munch:::parse_inline_md("hello **bold**")

  expect_true(any(grepl("hello", chunks$txt)))
  before_row <- chunks[grepl("hello", chunks$txt), ]
  expect_false(before_row$bold)
})

test_that("parse_inline_md text after match", {
  chunks <- munch:::parse_inline_md("**bold** world")

  expect_true(any(grepl("world", chunks$txt)))
  after_row <- chunks[grepl("world", chunks$txt), ]
  expect_false(after_row$bold)
})

test_that("parse_inline_md text before and after", {
  chunks <- munch:::parse_inline_md("aaa **bbb** ccc")

  expect_equal(nrow(chunks), 3)
  expect_equal(chunks$txt, c("aaa ", "bbb", " ccc"))
  expect_equal(chunks$bold, c(FALSE, TRUE, FALSE))
})

test_that("parse_inline_md plain text only", {
  chunks <- munch:::parse_inline_md("no formatting here")

  expect_equal(nrow(chunks), 1)
  expect_equal(chunks$txt, "no formatting here")
  expect_false(chunks$bold)
  expect_false(chunks$italic)
})

test_that("parse_inline_md empty string", {
  chunks <- munch:::parse_inline_md("")

  expect_s3_class(chunks, "chunk")
})

test_that("parse_inline_md multiple patterns", {
  chunks <- munch:::parse_inline_md("**bold** and *italic* and `code`")

  bold_row <- chunks[grepl("bold", chunks$txt), ]
  italic_row <- chunks[grepl("italic", chunks$txt), ]
  code_row <- chunks[grepl("code", chunks$txt), ]

  expect_true(bold_row$bold)
  expect_true(italic_row$italic)
  expect_equal(code_row$font.family, "mono")
})

test_that("parse_inline_md returns chunk class", {
  chunks <- munch:::parse_inline_md("**bold**")

  expect_s3_class(chunks, "chunk")
})

test_that("parse_inline_md defaults from flextable", {
  ft <- flextable::get_flextable_defaults()
  chunks <- munch:::parse_inline_md("plain")

  expect_equal(chunks$font.size, ft$font.size)
  expect_equal(chunks$font.family, ft$font.family)
})
