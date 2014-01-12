module Graphics.Formats.STL.Printer where

import Data.Text (Text, unpack)
import Linear
import Text.PrettyPrint

import Graphics.Formats.STL.Types

pretty :: STL -> Doc
pretty s = vcat [ text "solid " <> (text . unpack $ name s)
                , vcat . map triangle $ triangles s
                , text "endsolid " <> (text . unpack $ name s)
                ]

triangle :: Triangle -> Doc
triangle (Triangle n (V3 a b c)) =
    vcat [ text "facet normal" <+> v3 n
         , nest 4 $ vcat [ text "outer loop"
                         , nest 4 $ vcat [vertex a, vertex b, vertex c]
                         , text "endloop"
                         ]
         , text "endfacet"
         ]

vertex :: Vector -> Doc
vertex v = text "vertex" <+> v3 v

v3 :: Vector -> Doc
v3 (V3 x y z) = hsep [float x, float y, float z]
