module TextMessages.Helpers exposing (addMessages, latestThreads, messagesForContactId, updateThreadState)

import Contacts.Models exposing (ContactId)
import Dict exposing (Dict)
import List exposing (concat, foldr, reverse, sortBy)
import List.Extra exposing (uniqueBy)
import Models exposing (ThreadState, Uid)
import TextMessages.Models exposing (TextMessage, threadContactId)


addMessages : List TextMessage -> List TextMessage -> List TextMessage
addMessages existingMessages newMessages =
    concat [ existingMessages, newMessages ] |> uniqueBy .id


messagesForContactId : ContactId -> List TextMessage -> List TextMessage
messagesForContactId contactId =
    List.filter (textMessageMatchesContact contactId) >> sortBy .id


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


updateThreadState : ThreadState -> List ThreadState -> List ThreadState
updateThreadState desiredThreadState threadStates =
    List.map (updateThreadStateIfMatches desiredThreadState) threadStates


updateThreadStateIfMatches : ThreadState -> ThreadState -> ThreadState
updateThreadStateIfMatches desiredThreadState existingThreadState =
    if desiredThreadState.uid == existingThreadState.uid then
        desiredThreadState
    else
        existingThreadState
