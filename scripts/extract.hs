import Text.HTML.TagSoup
import Text.JSON
import Data.List (isInfixOf, isPrefixOf, sortBy, groupBy, find)
import Data.Ord (comparing)
import System.Environment (getArgs)
import Data.Maybe (mapMaybe, fromJust, fromMaybe)

main = do
  mpopups <- fmap decode $ readFile "popups.json"
  case mpopups of
    Ok (JSArray popups) -> do
      fes <- readFile "entries.html"
      let titles = parseTags fes
      entries <- mapM (extract popups) $ getIdsClass titles
      let sections =
            groupBy (\e1 e2 ->
                      startSection e1 == startSection e2)
            $ sortBy (comparing start) entries
      mapM writeJson (zip timeRanges sections)
    a -> error ("couldn't read popups: " ++ (show a))
 where start (_,_,_,_,x,_,_,_) = x
       startSection e = fromJust $ find ((start e) <) timeRanges

writeJson ::
  (Int, [(String,String,String,String,Int,Int,String,String)]) ->
  IO ()
writeJson (section, entries) = do
  let dat = encode $ JSArray $ map writeJson' entries
  writeFile ("data_" ++ (show section) ++ ".json") dat
    where writeJson' (eid,title,typ,loc,start,end,entry,source) =
            JSObject $
            toJSObject [("id", JSString $ toJSString eid)
                       ,("title", JSString $ toJSString title)
                       ,("type", JSString $ toJSString typ)
                       ,("loc", JSString $ toJSString loc)
                       ,("start", showJSON start)
                       ,("end", showJSON end)
                       ,("entry", JSString $ toJSString entry)
                       ,("source", JSString $ toJSString source)]

getIdsClass tags =
  let links = partitions (\t -> (isTagOpenName "a" t)) tags in
  filter ((/= "").fst) $ map (\a -> (fromAttrib "id" (head a), fromAttrib "class" (head a))) $ filter (/= []) links

types :: [String]
types = ["power", "redstar", "ind", "culture", "economy", "envir", "massacre"]

-- years to start sections at (ie, everything before 1600, etc).
timeRanges :: [Int]
timeRanges = [2050]

extract :: [JSValue] -> (String,String) ->
           IO (String,String,String,String,Int,Int,String,String)
extract popups (id',cls) = do
    let typ = fromMaybe "" $ headSafe $ filter (flip elem types) (words cls)
    let loc = fromMaybe "" $ headSafe $ filter (not . (flip elem ("fb" : types))) (words cls)
    fil <- fmap parseTags $ readFile $ "lam/" ++ id' ++ ".html"
    let headline = getPClass "headline" fil
    let entry = renderTags $ getPClassFilter "entry" fil
    let source = getPClass "source" fil
    let start = getVal "start" id'
    let end = getVal "end" id'
    return (id',headline,typ,loc,
            fromMaybe (-1) start, fromMaybe (-1) end,
            entry,source)
  where getPClass n ts = renderTags $ drop 1 $ getTag "p" n ts
        getVal str id =
          fmap (fromResult . valFromObj str) $ headSafe $
            filter (\o -> (fromResult $ valFromObj "id" o) == id) $ map getObj $ filter isObj popups
        isObj (JSObject _) = True
        isObj _ = False
        getObj (JSObject jso) = jso
        getObj _ = error "getObj passed non-JSObject"
        fromResult (Ok a) = a
        fromResult _ = error "fromResult on non-okay"

getPClassFilter n ts = let pstart = dropWhile (notIsTagClass "p" n) ts in
  case pstart of
    [] -> []
    _ -> let (p, ts') = break (isTagCloseName "p") pstart in
      case ts' of
        [] -> error "can not find closing tag"
        (close:rest) ->
          (p ++ [close]) ++ (getPClassFilter n rest)
        
notIsTagClass n c t = (not $ isTagOpenName n t) ||
                   (not $ (c `isInfixOf` (fromAttrib "class" t)))

getTag n c ts = takeWhile (not.isTagCloseName n) $
                dropWhile (notIsTagClass n c)
                ts
getText = maybe "" fromTagText
headSafe [] = Nothing
headSafe x = Just (head x)
