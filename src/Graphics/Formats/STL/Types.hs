module Graphics.Formats.STL.Types where

import Data.Text (Text)
import Linear

data STL = STL { name :: Text
               , triangles :: [Triangle]
               }

data Triangle = Triangle { normal :: Vector
                         , vertices :: V3 Vector
                         }

type Vector = V3 Float
