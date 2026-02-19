# =============================================================================
# Exemple d'utilisation de munch avec ggiraph
# =============================================================================

library(munch)
library(ggplot2)
library(ggiraph)
library(grid)
library(gdtools)
font_set_liberation()

# -----------------------------------------------------------------------------
# Exemple 1: Annotation markdown simple
# -----------------------------------------------------------------------------

# Créer un grob markdown
md_annotation <- md_grob(
  "**Corrélation** entre *mpg* et *wt*\n\n`r = -0.87`",
  hjust = 0,
  vjust = 1,
  width = 2,
  text_props = default_text_props(font_size = 11)
)

# ggplot avec points interactifs
p1 <- ggplot(mtcars, aes(x = mpg, y = wt)) +
  geom_point_interactive(
    aes(
      tooltip = paste0(
        "<b>",
        rownames(mtcars),
        "</b><br>",
        "MPG: ",
        mpg,
        "<br>",
        "Weight: ",
        wt,
        " (1000 lbs)"
      ),
      data_id = rownames(mtcars)
    ),
    size = 3,
    color = "steelblue"
  ) +
  annotation_custom(
    grob = md_annotation,
    xmin = 25,
    xmax = 35,
    ymin = 4.5,
    ymax = 5.5
  ) +
  labs(
    title = "Motor Trend Car Road Tests",
    x = "Miles per Gallon",
    y = "Weight (1000 lbs)"
  ) +
  theme_minimal(base_family = "Liberation Sans", base_size = 11)

# Créer le widget interactif
girafe(
  ggobj = p1,
  options = list(
    opts_hover(css = "fill:orange;stroke:orange;cursor:pointer;"),
    opts_tooltip(
      css = "background-color:white;padding:8px;border-radius:4px;border:1px solid #ccc;"
    )
  ),
  dependencies = list(
    liberationsansHtmlDependency()
  )
)

# -----------------------------------------------------------------------------
# Exemple 2: Légende markdown personnalisée
# -----------------------------------------------------------------------------

# Données avec groupes
df <- data.frame(
  x = c(1, 2, 3, 4, 5),
  y = c(2, 4, 3, 5, 4),
  group = c("A", "A", "B", "B", "B")
)

# Créer une légende markdown
legend_grob <- md_grob(
  "**Groupes:**
- *Groupe A*: données initiales
- *Groupe B*: données finales",
  hjust = 0,
  vjust = 1,
  width = 2, # Largeur max pour wrapping
  text_props = default_text_props(font_size = 9)
)

p2 <- ggplot(df, aes(x, y, color = group)) +
  geom_point_interactive(
    aes(tooltip = paste("Groupe:", group)),
    size = 4
  ) +
  geom_line() +
  annotation_custom(
    grob = legend_grob,
    xmin = 2.5,
    xmax = 4.5,
    ymin = 4.5,
    ymax = 5.5
  ) +
  scale_color_manual(values = c("A" = "#E41A1C", "B" = "#377EB8")) +
  theme_minimal(base_family = "Liberation Sans", base_size = 11) +
  theme(legend.position = "none")

girafe(
  ggobj = p2,
  dependencies = list(
    liberationsansHtmlDependency()
  )
)
