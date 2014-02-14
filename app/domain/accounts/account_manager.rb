module Accounts
  class AccountManager
    extend Forwardable

    def_delegators :@account_linker, :not_merging?, :valid_merge?, :merging_state, :merging_user, :offending_identities, :determine_state

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
      Rails.logger.info "OVOJEZAGREP new_account #{new_account.inspect}"
      @current_user || @identity.user || new_account
    end

    def link_and_merge
      account_linker.determine_state.link
    end

    def linker
      @account_linker
    end

    private
    def new_account
      (@account_creator ||= AccountCreator.new(@identity)).create
    end

  end
end
