module Accounts
  class AccountManager
    extend Forwardable

    def_delegators :@account_linker, :not_merging?,
      :invalid_merge?, :valid_merge?, :merging_state,
      :merging_user, :offending_identities

    def initialize(provider, identity, current_user = nil)
      @provider = provider
      @identity = identity
      @current_user = current_user
    end

    def linking_or_merging?
      @current_user.present? && not(@current_user.identities.include?(@identity))
    end

    def only_logging_in?
      @current_user.nil? || @current_user.identities.include?(@identity)
    end

    def procure
      @current_user || @identity.user || new_account
    end

    def link_and_merge
      account_linker.determine_state.link
    end

    def determine_state
      linker.determine_state
    end

    def linker
      @account_linker ||= AccountLinker.new(@current_user, @identity)
    end

    private
    def new_account
      (@account_creator ||= AccountCreator.new(@identity)).create
    end

  end
end
