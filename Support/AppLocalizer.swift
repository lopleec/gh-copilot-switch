import Foundation

enum AppCopy {
    case appDisplayName
    case menuProfiles
    case menuNewProfile
    case menuEditSelectedProfile
    case menuApplySelectedProfile
    case menuDeactivateCurrentProfile

    case toolbarNewProfile
    case toolbarEditProfile
    case toolbarDeleteProfile
    case toolbarApplyToCopilot
    case toolbarDeactivateCurrentProfile
    case toolbarSettings

    case emptySelectionTitle
    case emptySelectionDescription
    case profileListEmptyTitle
    case profileListEmptyDescription

    case alertDeleteTitle
    case alertDeleteAction
    case actionCancel
    case alertDeleteMessageFormat

    case profileDetailDescriptionFormat
    case profileActive
    case profileInactive
    case editProfile
    case deleteProfile
    case applyToCopilot
    case deactivateCurrentProfile

    case configSectionTitle
    case providerType
    case baseURL
    case model
    case apiKey
    case managedTargetFile
    case managedShellSyntax
    case savedToKeychain
    case notSet
    case lastApplied
    case managedBlockSectionTitle
    case managedBlockDescription
    case managedBlockHint
    case modelUnset

    case editorCreateTitle
    case editorEditTitle
    case editorProfileName
    case editorGeneralInfo
    case editorEnvironmentSection
    case editorEnvironmentFooter
    case saveProfile

    case settings
    case settingsGeneralTab
    case settingsAppearanceSection
    case settingsLanguage
    case settingsNotificationDuration
    case settingsIntegrationSection
    case settingsManagedFile
    case settingsManagedBehavior
    case settingsTargetFilePath
    case settingsTargetFileHint
    case settingsShellSyntax
    case settingsEditTargetFile
    case settingsSaveTargetFile
    case settingsLanguageSystem
    case settingsLanguageChinese
    case settingsLanguageEnglish
    case settingsShellSyntaxPosix
    case settingsShellSyntaxFish
    case durationBrief
    case durationStandard
    case durationLong

    case validationMissingName
    case validationInvalidBaseURL
    case validationMissingModel
    case defaultProfileName

    case toggleDeactivateHelp
    case toggleActivateHelp
    case dismissStatusBanner
    case dismissStatusBannerHint

    case providerOpenAICompatible
    case providerAzureOpenAI
    case providerAnthropic
    case keychainUnexpectedStatusFormat
    case keychainUnknownError
    case keychainInvalidData

    case statusReadAPIKeyFailedFormat
    case statusProfileAdded
    case statusEditMissingProfile
    case statusProfileSavedAndSyncedFormat
    case statusProfileSaved
    case statusSaveFailedFormat
    case statusManagedConfigRemovedFormat
    case statusDeactivateFailedFormat
    case statusApplyMissingProfile
    case statusAppliedProfileFormat
    case statusApplyFailedFormat
    case statusProfileDeleted
    case statusDeleteFailedFormat
    case statusLoadFailedFormat
}

struct AppLocalizer {
    let language: AppLanguage

    var locale: Locale {
        language.locale
    }

    func string(_ key: AppCopy) -> String {
        template(for: key)
    }

    func string(_ key: AppCopy, _ arguments: CVarArg...) -> String {
        String(format: template(for: key), locale: locale, arguments: arguments)
    }

    private func template(for key: AppCopy) -> String {
        switch language.resolvedLanguage {
        case .simplifiedChinese:
            switch key {
            case .appDisplayName:
                return "GitHub Copilot LLM Switch"
            case .menuProfiles:
                return "配置"
            case .menuNewProfile:
                return "新增配置"
            case .menuEditSelectedProfile:
                return "编辑当前配置"
            case .menuApplySelectedProfile:
                return "应用当前配置"
            case .menuDeactivateCurrentProfile:
                return "停用当前配置"
            case .toolbarNewProfile:
                return "新增配置"
            case .toolbarEditProfile:
                return "编辑配置"
            case .toolbarDeleteProfile:
                return "删除配置"
            case .toolbarApplyToCopilot:
                return "应用到 Copilot"
            case .toolbarDeactivateCurrentProfile:
                return "停用当前配置"
            case .toolbarSettings:
                return "设置"
            case .emptySelectionTitle:
                return "还没有配置"
            case .emptySelectionDescription:
                return "先新增一个模型配置，再选择要写入 GitHub Copilot CLI 的那一个。"
            case .profileListEmptyTitle:
                return "没有可用配置"
            case .profileListEmptyDescription:
                return "点击工具栏上的加号，新增第一个 Copilot CLI 模型配置。"
            case .alertDeleteTitle:
                return "删除这个配置？"
            case .alertDeleteAction:
                return "删除"
            case .actionCancel:
                return "取消"
            case .alertDeleteMessageFormat:
                return "“%@” 会从列表中移除；如果它当前已生效，对应的受管 shell 配置也会一并清除。"
            case .profileDetailDescriptionFormat:
                return "用于 GitHub Copilot CLI 的 %@ 模型配置。"
            case .profileActive:
                return "当前正在使用"
            case .profileInactive:
                return "未启用"
            case .editProfile:
                return "编辑配置"
            case .deleteProfile:
                return "删除配置"
            case .applyToCopilot:
                return "应用到 Copilot"
            case .deactivateCurrentProfile:
                return "停用当前配置"
            case .configSectionTitle:
                return "Copilot CLI 配置"
            case .providerType:
                return "Provider Type"
            case .baseURL:
                return "Base URL"
            case .model:
                return "Model"
            case .apiKey:
                return "API Key"
            case .managedTargetFile:
                return "目标文件"
            case .managedShellSyntax:
                return "Shell 语法"
            case .savedToKeychain:
                return "已保存到钥匙串"
            case .notSet:
                return "未设置"
            case .lastApplied:
                return "最近写入"
            case .managedBlockSectionTitle:
                return "受管配置预览"
            case .managedBlockDescription:
                return "应用配置时，只会替换本工具自己的受管区块，不会重写你其他的 shell 设置。"
            case .managedBlockHint:
                return "提示：zsh/bash 使用 export，fish 使用 set -gx；本地 Ollama 等无鉴权端点可以不填写 API Key。"
            case .modelUnset:
                return "未设置模型"
            case .editorCreateTitle:
                return "新增配置"
            case .editorEditTitle:
                return "编辑配置"
            case .editorProfileName:
                return "配置名称"
            case .editorGeneralInfo:
                return "基本信息"
            case .editorEnvironmentSection:
                return "Copilot CLI 环境变量"
            case .editorEnvironmentFooter:
                return "如果提供商不要求鉴权，例如本地 Ollama，可将 API Key 留空。"
            case .saveProfile:
                return "保存配置"
            case .settings:
                return "设置"
            case .settingsGeneralTab:
                return "通用"
            case .settingsAppearanceSection:
                return "外观与提示"
            case .settingsLanguage:
                return "界面语言"
            case .settingsNotificationDuration:
                return "提醒停留时长"
            case .settingsIntegrationSection:
                return "Copilot 集成"
            case .settingsManagedFile:
                return "受管配置"
            case .settingsManagedBehavior:
                return "应用配置时，只会更新 GitHubCopilotLLMSwitch 自己写入的受管区块。切换目标文件后，重新应用一次当前配置即可迁移。"
            case .settingsTargetFilePath:
                return "目标文件路径"
            case .settingsTargetFileHint:
                return "例如：~/.zshrc、~/.bash_profile、~/.config/fish/config.fish"
            case .settingsShellSyntax:
                return "Shell 语法"
            case .settingsEditTargetFile:
                return "编辑"
            case .settingsSaveTargetFile:
                return "保存路径"
            case .settingsLanguageSystem:
                return "跟随系统"
            case .settingsLanguageChinese:
                return "简体中文"
            case .settingsLanguageEnglish:
                return "English"
            case .settingsShellSyntaxPosix:
                return "POSIX export（zsh / bash）"
            case .settingsShellSyntaxFish:
                return "Fish set -gx"
            case .durationBrief:
                return "短"
            case .durationStandard:
                return "标准"
            case .durationLong:
                return "长"
            case .validationMissingName:
                return "请填写一个易识别的配置名称。"
            case .validationInvalidBaseURL:
                return "Base URL 必须是有效的 http 或 https 地址。"
            case .validationMissingModel:
                return "请填写 Copilot 要使用的模型名称。"
            case .defaultProfileName:
                return "新配置"
            case .toggleDeactivateHelp:
                return "关闭后会清除当前受管 shell 配置"
            case .toggleActivateHelp:
                return "打开后会把这个配置写入当前受管文件"
            case .dismissStatusBanner:
                return "关闭提示"
            case .dismissStatusBannerHint:
                return "关闭这条状态提示"
            case .providerOpenAICompatible:
                return "OpenAI Compatible"
            case .providerAzureOpenAI:
                return "Azure OpenAI"
            case .providerAnthropic:
                return "Anthropic"
            case .keychainUnexpectedStatusFormat:
                return "钥匙串操作失败：%@ (%d)"
            case .keychainUnknownError:
                return "未知错误"
            case .keychainInvalidData:
                return "钥匙串返回了无法识别的 API Key 数据。"
            case .statusReadAPIKeyFailedFormat:
                return "无法读取当前配置的 API Key：%@"
            case .statusProfileAdded:
                return "已新增配置。"
            case .statusEditMissingProfile:
                return "要编辑的配置不存在。"
            case .statusProfileSavedAndSyncedFormat:
                return "已保存配置，并同步写入 %@。"
            case .statusProfileSaved:
                return "已保存配置。"
            case .statusSaveFailedFormat:
                return "保存失败：%@"
            case .statusManagedConfigRemovedFormat:
                return "已从 %@ 移除受管 Copilot 配置。"
            case .statusDeactivateFailedFormat:
                return "停用失败：%@"
            case .statusApplyMissingProfile:
                return "要应用的配置不存在。"
            case .statusAppliedProfileFormat:
                return "已将 %@ 写入 %@。重新打开终端后 Copilot CLI 会使用这个模型。"
            case .statusApplyFailedFormat:
                return "应用失败：%@"
            case .statusProfileDeleted:
                return "已删除配置。"
            case .statusDeleteFailedFormat:
                return "删除失败：%@"
            case .statusLoadFailedFormat:
                return "无法读取本地配置：%@"
            }

        case .english:
            switch key {
            case .appDisplayName:
                return "GitHub Copilot LLM Switch"
            case .menuProfiles:
                return "Profiles"
            case .menuNewProfile:
                return "New Profile"
            case .menuEditSelectedProfile:
                return "Edit Selected Profile"
            case .menuApplySelectedProfile:
                return "Apply Selected Profile"
            case .menuDeactivateCurrentProfile:
                return "Deactivate Current Profile"
            case .toolbarNewProfile:
                return "New Profile"
            case .toolbarEditProfile:
                return "Edit Profile"
            case .toolbarDeleteProfile:
                return "Delete Profile"
            case .toolbarApplyToCopilot:
                return "Apply to Copilot"
            case .toolbarDeactivateCurrentProfile:
                return "Deactivate Current Profile"
            case .toolbarSettings:
                return "Settings"
            case .emptySelectionTitle:
                return "No profiles yet"
            case .emptySelectionDescription:
                return "Create a model profile first, then choose the one GitHub Copilot CLI should use."
            case .profileListEmptyTitle:
                return "No profiles available"
            case .profileListEmptyDescription:
                return "Click the plus button in the toolbar to create your first Copilot CLI model profile."
            case .alertDeleteTitle:
                return "Delete this profile?"
            case .alertDeleteAction:
                return "Delete"
            case .actionCancel:
                return "Cancel"
            case .alertDeleteMessageFormat:
                return "\"%@\" will be removed. If it is active, the managed shell configuration will be removed too."
            case .profileDetailDescriptionFormat:
                return "A %@ model profile for GitHub Copilot CLI."
            case .profileActive:
                return "Currently active"
            case .profileInactive:
                return "Inactive"
            case .editProfile:
                return "Edit Profile"
            case .deleteProfile:
                return "Delete Profile"
            case .applyToCopilot:
                return "Apply to Copilot"
            case .deactivateCurrentProfile:
                return "Deactivate Current Profile"
            case .configSectionTitle:
                return "Copilot CLI Configuration"
            case .providerType:
                return "Provider Type"
            case .baseURL:
                return "Base URL"
            case .model:
                return "Model"
            case .apiKey:
                return "API Key"
            case .managedTargetFile:
                return "Target File"
            case .managedShellSyntax:
                return "Shell Syntax"
            case .savedToKeychain:
                return "Saved in Keychain"
            case .notSet:
                return "Not set"
            case .lastApplied:
                return "Last written"
            case .managedBlockSectionTitle:
                return "Managed configuration preview"
            case .managedBlockDescription:
                return "Applying a profile only replaces the block managed by this app. Your other shell settings stay untouched."
            case .managedBlockHint:
                return "Tip: zsh/bash uses export while fish uses set -gx. Local endpoints like Ollama can leave API Key empty."
            case .modelUnset:
                return "Model not set"
            case .editorCreateTitle:
                return "New Profile"
            case .editorEditTitle:
                return "Edit Profile"
            case .editorProfileName:
                return "Profile Name"
            case .editorGeneralInfo:
                return "General"
            case .editorEnvironmentSection:
                return "Copilot CLI Environment Variables"
            case .editorEnvironmentFooter:
                return "Leave API Key empty for providers that do not require authentication, such as a local Ollama instance."
            case .saveProfile:
                return "Save Profile"
            case .settings:
                return "Settings"
            case .settingsGeneralTab:
                return "General"
            case .settingsAppearanceSection:
                return "Appearance & Notices"
            case .settingsLanguage:
                return "App Language"
            case .settingsNotificationDuration:
                return "Notice Duration"
            case .settingsIntegrationSection:
                return "Copilot Integration"
            case .settingsManagedFile:
                return "Managed Configuration"
            case .settingsManagedBehavior:
                return "Applying a profile only updates the block written by GitHubCopilotLLMSwitch. Reapply the active profile once after changing the target file."
            case .settingsTargetFilePath:
                return "Target File Path"
            case .settingsTargetFileHint:
                return "Examples: ~/.zshrc, ~/.bash_profile, ~/.config/fish/config.fish"
            case .settingsShellSyntax:
                return "Shell Syntax"
            case .settingsEditTargetFile:
                return "Edit"
            case .settingsSaveTargetFile:
                return "Save Path"
            case .settingsLanguageSystem:
                return "Follow System"
            case .settingsLanguageChinese:
                return "Simplified Chinese"
            case .settingsLanguageEnglish:
                return "English"
            case .settingsShellSyntaxPosix:
                return "POSIX export (zsh / bash)"
            case .settingsShellSyntaxFish:
                return "Fish set -gx"
            case .durationBrief:
                return "Brief"
            case .durationStandard:
                return "Standard"
            case .durationLong:
                return "Long"
            case .validationMissingName:
                return "Enter a recognizable profile name."
            case .validationInvalidBaseURL:
                return "Base URL must be a valid http or https address."
            case .validationMissingModel:
                return "Enter the model Copilot should use."
            case .defaultProfileName:
                return "New Profile"
            case .toggleDeactivateHelp:
                return "Turn off to remove the current managed shell configuration."
            case .toggleActivateHelp:
                return "Turn on to write this profile into the current managed file."
            case .dismissStatusBanner:
                return "Dismiss status"
            case .dismissStatusBannerHint:
                return "Dismiss this status message."
            case .providerOpenAICompatible:
                return "OpenAI Compatible"
            case .providerAzureOpenAI:
                return "Azure OpenAI"
            case .providerAnthropic:
                return "Anthropic"
            case .keychainUnexpectedStatusFormat:
                return "Keychain operation failed: %@ (%d)"
            case .keychainUnknownError:
                return "Unknown error"
            case .keychainInvalidData:
                return "The Keychain returned unreadable API key data."
            case .statusReadAPIKeyFailedFormat:
                return "Failed to read the API key: %@"
            case .statusProfileAdded:
                return "Profile created."
            case .statusEditMissingProfile:
                return "The profile to edit no longer exists."
            case .statusProfileSavedAndSyncedFormat:
                return "Profile saved and synced to %@."
            case .statusProfileSaved:
                return "Profile saved."
            case .statusSaveFailedFormat:
                return "Save failed: %@"
            case .statusManagedConfigRemovedFormat:
                return "Managed Copilot configuration removed from %@."
            case .statusDeactivateFailedFormat:
                return "Deactivate failed: %@"
            case .statusApplyMissingProfile:
                return "The selected profile no longer exists."
            case .statusAppliedProfileFormat:
                return "%@ was written to %@. Reopen Terminal and Copilot CLI will use this model."
            case .statusApplyFailedFormat:
                return "Apply failed: %@"
            case .statusProfileDeleted:
                return "Profile deleted."
            case .statusDeleteFailedFormat:
                return "Delete failed: %@"
            case .statusLoadFailedFormat:
                return "Failed to load local profiles: %@"
            }

        case .system:
            return ""
        }
    }
}
