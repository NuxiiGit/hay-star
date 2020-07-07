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
    decode xs = case parse (graph <|> digraph) xs of
        Just (g, []) -> g
        Just (_, s) -> error $ "expected EOF, got " ++ s
        _ -> error "failed to parse graph"

    -- |Parses a graph.
    graph :: Parser DotGraph
    graph = do
        symbol "graph"
        symbol "{"
        gs <- some $ statement $ subgraph "--"
        symbol "}"
        return $ symmetric $ concat gs

    -- |Parses a directed graph.
    digraph :: Parser DotGraph
    digraph = do
        symbol "digraph"
        symbol "{"
        gs <- some $ statement $ subgraph "->"
        symbol "}"
        return $ concat gs

    -- |Parses a subgraph.
    subgraph :: String -> Parser DotGraph
    subgraph separator = cluster separator <|> path separator

    -- |Parses a path of idenifiers into a simple subgraph.
    path :: String -> Parser DotGraph
    path separator = do
        x <- token identifier
        xs <- many $ symbol separator >> token identifier
        return $ graphify $ x : xs

    -- |Parses a cluster of identifiers into a simple tree-style subgraph.
    cluster :: String -> Parser DotGraph
    cluster separator = do
        x <- token identifier
        symbol separator
        symbol "{"
        xs <- many $ token identifier
        symbol "}"
        return [(x, x') | x' <- xs]