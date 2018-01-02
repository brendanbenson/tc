module ListUtils exposing (..)

import List exposing (foldr, member)


addIfNotExists : a -> List a -> List a
addIfNotExists a l =
    if member a l then
        l
    else
        a :: l
