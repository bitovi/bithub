module Accounts
  class AccountManager

    def_delegators :@account_linker, :not_merging?, :valid_merge?, :merging_state, :merging_user, :offending_identities
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
      @current_user || @identity.user || create_account
    end

    def link_and_merge
      account_linker.determine_state.link
    end

    private
    def create_account
      (@account_creator ||= AccountCreator.new(@identity)).create
    end

  end
end
