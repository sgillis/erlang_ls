%%==============================================================================
%% Base Protocol
%%==============================================================================
%% := indicates a mandatory key
%% => indicates an optional key
%%==============================================================================

%%------------------------------------------------------------------------------
%% JSON-RPC Version
%%------------------------------------------------------------------------------
-define(JSONRPC_VSN, <<"2.0">>).
-type jsonrpc_vsn() :: binary().

%%------------------------------------------------------------------------------
%% Abstract Message
%%------------------------------------------------------------------------------
-type message() :: #{ jsonrpc := jsonrpc_vsn()
                    }.

%%------------------------------------------------------------------------------
%% Request Message
%%------------------------------------------------------------------------------
-type request() :: #{ jsonrpc := jsonrpc_vsn()
                    , id      := number() | binary()
                    , method  := binary()
                    , params  => [any()] | map()
                    }.
%%------------------------------------------------------------------------------
%% Response Message
%%------------------------------------------------------------------------------
-type response() :: #{ jsonrpc := jsonrpc_vsn()
                     , id      := number() | binary() | null
                     , result  => any()
                     , error   => error(any())
                     }.

-type error(Type) :: #{ code    := number()
                      , message := binary()
                      , data    => Type
                      }.

%% Defined by JSON RPC
-define(ERR_PARSE_ERROR            , -32700).
-define(ERR_INVALID_REQUEST        , -32600).
-define(ERR_METHOD_NOT_FOUND       , -32601).
-define(ERR_INVALID_PARAMS         , -32602).
-define(ERR_INTERNAL_ERROR         , -32603).
-define(ERR_SERVER_ERROR_START     , -32099).
-define(ERR_SERVER_ERROR_END       , -32000).
-define(ERR_SERVER_NOT_INITIALIZED , -32002).
-define(ERR_UNKNOWN_ERROR_CODE     , -32001).

%% Defined by the protocol
-define(ERR_REQUEST_CANCELLED      , -32800).

%%------------------------------------------------------------------------------
%% Notification Message
%%------------------------------------------------------------------------------
-type notification() :: #{ jsonrpc := jsonrpc_vsn()
                         , method  := binary()
                         , params  => [any()] | map()
                         }.

%%------------------------------------------------------------------------------
%% Cancellation Support
%%------------------------------------------------------------------------------
-type cancel_params() :: #{ id := number() | binary()
                          }.

%%==============================================================================
%% Language Server Protocol
%%==============================================================================

%%------------------------------------------------------------------------------
%% URI
%%------------------------------------------------------------------------------
-type uri() :: binary().

%%------------------------------------------------------------------------------
%% Position
%%------------------------------------------------------------------------------
-type position() :: #{ line      := number()
                     , character := number()
                     }.

%%------------------------------------------------------------------------------
%% Range
%%------------------------------------------------------------------------------
-type range() :: #{ start := position()
                  , 'end' := position()
                  }.

%%------------------------------------------------------------------------------
%% Location
%%------------------------------------------------------------------------------
-type location() :: #{ uri   := binary()
                     , range := range()
                     }.

%%------------------------------------------------------------------------------
%% Diagnostic
%%------------------------------------------------------------------------------
-type diagnostic() :: #{ range              := range()
                       , severity           => severity()
                       , code               => number() | binary()
                       , source             => binary()
                       , message            := binary()
                       , relatedInformation => [related_info()]
                       }.

-define(DIAGNOSTIC_ERROR   , 1).
-define(DIAGNOSTIC_WARNING , 2).
-define(DIAGNOSTIC_INFO    , 3).
-define(DIAGNOSTIC_HINT    , 4).

-type severity() :: ?DIAGNOSTIC_ERROR
                  | ?DIAGNOSTIC_WARNING
                  | ?DIAGNOSTIC_INFO
                  | ?DIAGNOSTIC_HINT.

-type related_info() :: #{ location := location()
                         , message  := binary()
                         }.

%%------------------------------------------------------------------------------
%% Command
%%------------------------------------------------------------------------------
-type command() :: #{ title     := binary()
                    , command   := binary()
                    , arguments => [any()]
                    }.

%%------------------------------------------------------------------------------
%% Text Edit
%%------------------------------------------------------------------------------
-type text_edit() :: #{ range   := range()
                      , newText := binary()
                      }.

%%------------------------------------------------------------------------------
%% Text Document Edit
%%------------------------------------------------------------------------------
-type text_document_edit() :: #{ textDocument := versioned_text_document_id()
                               , edits        := [text_edit()]
                               }.

%%------------------------------------------------------------------------------
%% Workspace Edit
%%------------------------------------------------------------------------------
-type workspace_edit() :: #{ changes         => #{ binary() := [text_edit()]
                                                 }
                           , documentChanges => [text_document_edit()]
                           }.

%%------------------------------------------------------------------------------
%% Text Document Identifier
%%------------------------------------------------------------------------------
-type text_document_id() :: #{ uri := uri() }.

%%------------------------------------------------------------------------------
%% Text Document Item
%%------------------------------------------------------------------------------
-type text_document_item() :: #{ uri        := uri()
                               , languageId := binary()
                               , version    := number()
                               , text       := binary()
                               }.

%%------------------------------------------------------------------------------
%% Versioned Text Document Identifier
%%------------------------------------------------------------------------------
-type versioned_text_document_id() :: #{ version := number() | null
                                       }.

%%------------------------------------------------------------------------------
%% Text Document Position Params
%%------------------------------------------------------------------------------
-type text_document_position_params() :: #{ textDocument := text_document_id()
                                          , position     := position()
                                          }.

%%------------------------------------------------------------------------------
%% Document Fiter
%%------------------------------------------------------------------------------
-type document_filter() :: #{ language => binary()
                            , scheme   => binary()
                            , pattern  => binary()
                            }.

-type document_selector() :: [document_filter()].

%%------------------------------------------------------------------------------
%% Markup Content
%%------------------------------------------------------------------------------
-define(PLAINTEXT , plaintext).
-define(MARKDOWN  , markdown).

-type markup_kind() :: ?PLAINTEXT
                     | ?MARKDOWN.

-type markup_content() :: #{ kind  := markup_kind()
                           , value := binary()
                           }.

%%==============================================================================
%% Actual Protocol
%%==============================================================================

%%------------------------------------------------------------------------------
%% Initialize Request
%%------------------------------------------------------------------------------
-type workspace_folder() :: #{ uri  => uri()
                             , name => binary()
                             }.

-define(COMPLETION_ITEM_KIND_TEXT, 1).
-type completion_item_kind() :: ?COMPLETION_ITEM_KIND_TEXT.

-define(SYMBOL_KIND_FILE, 1).
-type symbol_kind() :: ?SYMBOL_KIND_FILE.

-define(CODE_ACTION_KIND_QUICKFIX, 1).
-type code_action_kind() :: ?CODE_ACTION_KIND_QUICKFIX.

-type initialize_params() :: #{ processId             := number() | null
                              , rootPath              => binary() | null
                              , rootUri               := uri() | null
                              , initializationOptions => any()
                              , capabilities          := client_capabilities()
                              , trace                 => off
                                                       | messages
                                                       | verbose
                              , workspaceFolders      => [workspace_folder()]
                                                       | null
                              }.

-type client_capabilities() ::
        #{ workspace    => workspace_client_capabilities()
         , textDocument => text_document_client_capabilities()
         , experimental => any()
         }.

-type workspace_client_capabilities() ::
        #{ applyEdit => boolean()
         , workspaceEdit =>
             #{ documentChanges => boolean()
              }
         , didChangeConfiguration =>
             #{ dynamicRegistration => boolean()
              }
         , didChangeWatchedFiles =>
             #{ dynamicRegistration => boolean()
              }
         , symbol =>
             #{ dynamicRegistration => boolean()
              , symbolKind =>
                  #{ valueSet => [symbol_kind()]
                   }
              }
         , executeCommand =>
             #{ dynamicRegistration => boolean()
              }
         , workspaceFolders => boolean()
         , configuration => boolean()
         }.

-type text_document_client_capabilities() ::
        #{ synchronization =>
             #{ dynamicRegistration => boolean()
              , willSave => boolean()
              , willSaveWaitUntil => boolean()
              , didSave => boolean()
              }
         , completion =>
             #{ dynamicRegistration => boolean()
              , completionItem =>
                  #{ snippetSupport => boolean()
                   , commitCharactersSupport => boolean()
                   , documentationFormat => markup_kind()
                   , deprecatedSupport => boolean()
                   }
              , completionItemKind =>
                  #{ valueSet => [completion_item_kind()]
                   }
              , contextSupport => boolean()
              }
         , hover =>
             #{ dynamicRegistration => boolean()
              , contentFormat => [markup_kind()]
              }
         , signatureHelp =>
             #{ dynamicRegistration => boolean()
              , signatureInformation =>
                  #{ documentationFormat => [markup_kind()]
                   }
              }
         , references =>
             #{ dynamicRegistration => boolean()
              }
         , documentHighlight =>
             #{ dynamicRegistration => boolean()
              }
         , documentSymbol =>
             #{ dynamicRegistration => boolean()
              , symbolKind =>
                  #{ valueSet => [symbol_kind()]
                   }
              }
         , formatting =>
             #{ dynamicRegistration => boolean()
              }
         , rangeFormatting =>
             #{ dynamicRegistration => boolean()
              }
         , onTypeFormatting =>
             #{ dynamicRegistration => boolean()
              }
         , definition =>
             #{ dynamicRegistration => boolean()
              }
         , typeDefinition =>
             #{ dynamicRegistration => boolean()
              }
         , implementation =>
             #{ dynamicRegistration => boolean()
              }
         , codeAction =>
             #{ dynamicRegistration => boolean()
              , codeActionLiteralSupport =>
                  #{ codeActionKind :=
                       #{ valueSet := [code_action_kind()]
                        }
                   }
              }
         , codeLens =>
             #{ dynamicRegistration => boolean()
              }
         , documentLink =>
             #{ dynamicRegistration => boolean()
              }
         , colorProvider =>
             #{ dynamicRegistration => boolean()
              }
         , rename =>
             #{ dynamicRegistration => boolean()
              }
         , publishDiagnostics =>
             #{ relatedInformation => boolean()
              }
         }.
