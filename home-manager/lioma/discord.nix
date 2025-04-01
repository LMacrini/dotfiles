{inputs, ...}: {
  imports = [
    inputs.nixcord.homeManagerModules.nixcord
  ];

  programs.nixcord = {
    enable = true;
    config = {
      frameless = true;
      enableReactDevtools = true;
      transparent = true;
      themeLinks = [
        "https://catppuccin.github.io/discord/dist/catppuccin-macchiato-pink.theme.css"
      ];

      plugins = {
        accountPanelServerProfile = {
          enable = true;
          prioritizeServerProfile = false;
        };

        alwaysAnimate.enable = true;

        alwaysExpandRoles.enable = true;

        alwaysTrust = {
          enable = true;
          domain = true;
          file = true;
        };

        betterFolders = {
          enable = true;
          sidebar = true;
          sidebarAnim = true;
          closeAllFolders = false;
          closeAllHomeButton = false;
          closeOthers = false;
          forceOpen = true;
          keepIcons = false;
          showFolderIcon = "always";
        };

        betterGifAltText.enable = true;

        betterNotesBox = {
          enable = true;
          hide = true;
          noSpellCheck = true;
        };

        betterRoleContext = {
          enable = true;
          roleIconFileFormat = "png";
        };

        betterSessions = {
          enable = true;
          backgroundCheck = false;
        };

        betterSettings.enable = true;

        betterUploadButton.enable = true;

        biggerStreamPreview.enable = true;

        blurNSFW.enable = true;

        clearURLs.enable = true;

        consoleJanitor.enable = true;

        consoleShortcuts.enable = true;

        copyFileContents.enable = true;

        crashHandler = {
          enable = true;
          attemptToNavigateToHome = true;
        };

        dearrow.enable = true;

        decor.enable = true;

        disableCallIdle.enable = true;

        dontRoundMyTimestamps.enable = true;

        fakeNitro.enable = true;

        fakeProfileThemes.enable = true;

        favoriteGifSearch.enable = true;

        fixCodeblockGap.enable = true;

        fixImagesQuality.enable = true;

        fixSpotifyEmbeds.enable = true;

        fixYoutubeEmbeds.enable = true;

        forceOwnerCrown.enable = true;

        friendsSince.enable = true;

        fullSearchContext.enable = true;

        fullUserInChatbox.enable = true;

        gameActivityToggle.enable = true;

        gifPaste.enable = true;

        hideAttachments.enable = true;

        iLoveSpam.enable = true;

        ignoreActivities = {};

        imageLink.enable = true;

        imageZoom = {
          enable = true;
          saveZoomValues = false;
        };

        implicitRelationships = {
          enable = true;
          sortByAffinity = true;
        };

        mentionAvatars.enable = true;

        messageTags = {
          enable = true;
          clyde = false;
        };

        moreCommands.enable = true;

        moreKaomoji.enable = true;

        moreUserTags = {
          dontShowForBots = true;
          tagSettings = {
            owner = {
              showInChat = false;
              showInNotChat = false;
            };
            administrator = {
              showInChat = false;
              showInNotChat = false;
            };
            moderator = {
              showInChat = false;
              showInNotChat = false;
            };
            voiceModerator = {
              showInChat = false;
              showInNotChat = false;
            };
            chatModerator = {
              showInChat = false;
              showInNotChat = false;
            };
          };
        };

        mutualGroupDMs.enable = true;

        newGuildSettings = {
          enable = true;
          messages = "only@Mentions";
          everyone = false;
          role = false;
        };

        noDevtoolsWarning.enable = true;

        noF1.enable = true;

        noMosaic.enable = true;

        noOnboardingDelay.enable = true;

        noPendingCount = {
          enable = true;
          hideFriendRequestsCount = false;
          hideMessageRequestCount = false;
        };

        noSystemBadge.enable = true;

        noTypingAnimation.enable = true;

        noUnblockToJump.enable = true;

        normalizeMessageLinks.enable = true;

        openInApp = {
          enable = true;
          spotify = true;
          steam = true;
        };

        pauseInvitesForever.enable = true;

        permissionFreeWill = {
          enable = true;
          lockout = false;
          onboarding = true;
        };

        permissionsViewer = {
          enable = true;
          permissionsSortOrder = "highestRole";
          defaultPermissionsDropdownState = false;
        };

        petpet.enable = true;

        previewMessage.enable = true;

        userMessagesPronouns.enable = true;

        quickMention.enable = true;

        quickReply.enable = true;

        reactErrorDecoder.enable = true;

        replaceGoogleSearch = {
          enable = true;
          customEngineName = "Duckduckgo";
          customEngineURL = "https://duckduckgo.com/";
        };

        revealAllSpoilers.enable = true;

        reverseImageSearch.enable = true;

        roleColorEverywhere = {
          enable = true;
          colorChatMessages = true;
        };

        sendTimestamps.enable = true;

        serverInfo.enable = true;

        shikiCodeblocks = {
          enable = true;
          theme = "https://raw.githubusercontent.com/synpixel/catppuccin-better-discord-shiki/main/macchiato.json";
          useDevIcon = "COLOR";
        };

        showTimeoutDuration.enable = true;

        sortFriendRequests = {
          enable = true;
          showDates = true;
        };

        spotifyControls = {
          enable = true;
          
          # TODO: figure out what this does
          hoverControls = false;
        };

        spotifyCrack.enable = true;

        spotifyShareCommands.enable = true;

        stickerPaste.enable = true;

        themeAttributes.enable = true;

        translate.enable = true;

        typingIndicator = {
          enable = true;
        };

        typingTweaks.enable = true;

        unindent.enable = true;

        unlockedAvatarZoom.enable = true;

        unsuppressEmbeds.enable = true;

        userVoiceShow.enable = true;

        USRBG = {
          enable = true;
          voiceBackground = false;
        };

        validReply.enable = true;
        validUser.enable = true;

        voiceChatDoubleClick.enable = true;

        vencordToolbox.enable = true;

        viewIcons.enable = true;

        viewRaw = {
          enable = true;
          clickMethod = "Right";
        };

        voiceDownload.enable = true;

        voiceMessages.enable = true;

        volumeBooster.enable = true;

        whoReacted.enable = true;

        youtubeAdblock.enable = true;

        webKeybinds.enable = true;
        webRichPresence.enable = true;
        webScreenShareFixes.enable = true;
      };
    };

    discord = {
      vencord.enable = true;
      openASAR.enable = true;
      # autoscroll.enable = true;
    };

    vesktop = {
      enable = true;
      # autoscroll.enable = true;
    };

    # NOTE: user plugins seem to be broken right now

    # userPlugins = let
    #   shyTyping = builtins.fetchGit {
    #     url = "https://git.nin0.dev/Sqaaakoi-VencordUserPlugins/shyTyping.git";
    #     rev = "a6f6a21cf5a64792cb049067b6e3536636fcfa37";
    #   };
    #   _ = builtins.trace shyTyping "";
    # in {
    #   shyTyping = "${shyTyping}";
    # };

    extraConfig = {
      plugins = {
        # shyTyping.enable = true;
      };
    };
  };
}
