-- |Suppies functions for importing and exporting DOT scripts.
module Dot (module Dot)
    where
    import Graph
    import Pathing
    import Parser

    import Control.Applicative

    {- TODO:
     - Add function for loading DOT scripts.
     - Add function for saving DOT scripts.
     -}
    
    -- |Type alias for dot graphs.
    type DotGraph = Graph String

    -- |Writes a graph to the DOT format.
    encode :: DotGraph -> String
    encode g = if isDirected g
        then let
            body = concat [a ++ " -> " ++ b ++ "; " | (a, b) <- g]
            in "digraph { " ++ body ++ "}"
        else let
            g' = antisymmetric g
            body = concat [a ++ " -- " ++ b ++ "; " | (a, b) <- g']
            in "graph { " ++ body ++ "}"

    -- |Writes a graph to the DOT format.
    decode :: String -> DotGraph
    decode xs = case parse graph xs of
        Just (g, []) -> g
        Just (_, s) -> error $ "expected EOF, got " ++ s
        _ -> error "failed to parse graph"

    -- |Parses a graph cluster.
    cluster :: Parser DotGraph
    cluster = graph <|> digraph

    -- |Parses a graph.
    graph :: Parser DotGraph
    graph = do
        token $ string "graph"
        token $ char '{'
        edge <- statement $ expr
        token $ char '}'
        return [edge]
        where
        expr = do
            l <- token $ string "a"
            token $ string "--"
            r <- token $ string "b"
            return (l, r)


    -- |Parses a directed graph.
    digraph :: Parser DotGraph
    digraph = undefined