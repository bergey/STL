import qualified Data.ByteString as BS
import           Data.Serialize
import           Options.Applicative

import           Graphics.Formats.STL

data Opts = Opts String

opts = Opts <$> argument Just (metavar "FILENAME" <> help "Input STL file")

copySTL :: Opts -> IO ()
copySTL (Opts fn) = do
    i <- BS.readFile fn
    case runGet (get :: Get STL) i of
        Left error -> do
            putStrLn $ "Encountered error reading "++fn
            putStrLn error
        Right stl -> do
            BS.writeFile "roundtrip.stl" . runPut . put $ stl
            putStrLn "wrote output to roundtrip.stl"

main :: IO ()
main = execParser withHelp >>= copySTL where
  withHelp = info (helper <*> opts)
               ( fullDesc <> progDesc "pretty print FILENAME"
                 <> header "binary-roundtrip - a test for STL library" )
