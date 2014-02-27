module Graphics.Formats.STL.Printer where

import Data.Text (Text, unpack)
import Text.PrettyPrint

import Graphics.Formats.STL.Types

-- | Convert an @STL@ value to a @Doc@, which can be converted to a
-- @String@ with 'render'
prettySTL :: STL -> Doc
prettySTL s = vcat [ text "solid " <> (text . unpack $ name s)
                , vcat . map triangle $ triangles s
                , text "endsolid " <> (text . unpack $ name s)
                ]

triangle :: Triangle -> Doc
triangle (Triangle n (a, b, c)) =
    vcat [ text "facet normal" <+> maybeNormal n
         , nest 4 $ vcat [ text "outer loop"
                         , nest 4 $ vcat [vertex a, vertex b, vertex c]
                         , text "endloop"
                         ]
         , text "endfacet"
         ]

maybeNormal n = case n of
    Nothing -> v3 (0,0,0)
    Just n' -> v3 n'

vertex :: Vector -> Doc
vertex v = text "vertex" <+> v3 v

v3 :: Vector -> Doc
v3 (x, y, z) = hsep [float x, float y, float z]
