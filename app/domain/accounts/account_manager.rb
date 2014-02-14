module Accounts
  class AccountManager

    attr_reader :account_linker

    def initialize(provider, identity, current_user = nil)
      @provider = provider
      @identity = identity
      @current_user = current_user
      @account_linker = AccountLinker.new(@current_user, @identity)
    end

    def linking_or_merging?
      @current_user.present? && not(@current_user.identities.include?(@identity))
    end

    def only_logging_in?
      @current_user.nil? || @current_user.identities.include?(@identity)
    end

    def procure
      @current_user || @identity.user || AccountCreator.new(@identity).create
    end

    def link_and_merge
      account_linker.determine_state.link
    end

    def determine_state
      account_linker.determine_state
      self
    end

    def not_merging?
      account_linker.not_merging?
    end

    def valid_merge?
      account_linker.valid_merge?
    end

    def invalid_merge?
      account_linker.invalid_merge?
    end

    def merging_state
      account_linker.merging_state
    end

    def merging_user
      account_linker.merging_user
    end

    def offending_identities
      account_linker.offending_identities
    end
  end
end
