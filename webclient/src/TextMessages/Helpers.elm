module TextMessages.Helpers exposing (..)

import Contacts.Models exposing (ContactId)
import Dict exposing (Dict)
import List exposing (append, concat, filter, foldr, reverse, sortBy)
import List.Extra exposing (uniqueBy)
import TextMessages.Models exposing (TextMessage, threadContactId)


addMessage : TextMessage -> List TextMessage -> List TextMessage
addMessage newMessage existingMessages =
    newMessage :: existingMessages |> uniqueBy .id


addMessages : List TextMessage -> List TextMessage -> List TextMessage
addMessages existingMessages newMessages =
    foldr addMessage existingMessages newMessages


messagesForContactId : ContactId -> List TextMessage -> List TextMessage
messagesForContactId contactId =
    filter (textMessageMatchesContact contactId) >> sortBy .id


textMessageMatchesContact : ContactId -> TextMessage -> Bool
textMessageMatchesContact contactId textMessage =
    if textMessage.incoming == True then
        textMessage.fromContact.id == contactId
    else
        textMessage.toContact.id == contactId


latestThreads : List TextMessage -> List TextMessage
latestThreads =
    foldr addTextMessageToThread Dict.empty >> Dict.values >> sortBy .id >> reverse


addTextMessageToThread : TextMessage -> Dict ContactId TextMessage -> Dict ContactId TextMessage
addTextMessageToThread textMessage threads =
    let
        contactId =
            threadContactId textMessage
    in
        case Dict.get contactId threads of
            Just existingMessage ->
                if existingMessage.id > textMessage.id then
                    threads
                else
                    Dict.insert contactId textMessage threads

            Nothing ->
                Dict.insert contactId textMessage threads