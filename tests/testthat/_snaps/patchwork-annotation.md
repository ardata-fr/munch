# munch_annotation rejects invalid caption type

    Code
      munch_annotation(caption = 123)
    Condition
      Error in `.check_annotation_arg()`:
      ! `caption` must be one of:
      * a character string
      * an `element_chunks()` or `element_md()` object
      * a `as_paragraph()` / chunk object from 'flextable'
      * NULL

# munch_annotation rejects invalid title type

    Code
      munch_annotation(title = list(a = 1))
    Condition
      Error in `.check_annotation_arg()`:
      ! `title` must be one of:
      * a character string
      * an `element_chunks()` or `element_md()` object
      * a `as_paragraph()` / chunk object from 'flextable'
      * NULL

