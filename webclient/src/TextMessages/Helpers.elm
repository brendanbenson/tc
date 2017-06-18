module TextMessages.Helpers exposing (addMessages, latestThreads, messagesForContactId, updateThreadState)

import Dict exposing (Dict)
import List exposing (concat, foldr, reverse, sortBy)
import List.Extra exposing (uniqueBy)
import ListUtils
import Models exposing (ContactId, TextMessage, ThreadState, Uid)


addMessages : List TextMessage -> List TextMessage -> List TextMessage
addMessages existingMessages newMessages =
    concat [ existingMessages, newMessages ] |> uniqueBy .id


latestThreads : List TextMessage -> List TextMessage
latestThreads =
    foldr addTextMessageToThread Dict.empty >> Dict.values >> sortBy .id >> reverse


messagesForContactId : ContactId -> List TextMessage -> List TextMessage
messagesForContactId contactId =
    List.filter (\t -> t.toContact.id == contactId) >> sortBy .id


addTextMessageToThread : TextMessage -> Dict ContactId TextMessage -> Dict ContactId TextMessage
addTextMessageToThread textMessage threads =
    case Dict.get textMessage.toContact.id threads of
        Just existingMessage ->
            if existingMessage.id > textMessage.id then
                threads
            else
                Dict.insert textMessage.toContact.id textMessage threads

        Nothing ->
            Dict.insert textMessage.toContact.id textMessage threads


updateThreadState : ThreadState -> List ThreadState -> List ThreadState
updateThreadState desiredThreadState threadStates =
    List.map (updateThreadStateIfMatches desiredThreadState) threadStates


updateThreadStateIfMatches : ThreadState -> ThreadState -> ThreadState
updateThreadStateIfMatches desiredThreadState existingThreadState =
    if desiredThreadState.uid == existingThreadState.uid then
        desiredThreadState
    else
        existingThreadState
