module Accounts
  class AccountManager
    extend Forwardable

    def_delegators :@account_linker, :not_merging?, :valid_merge?, :merging_state, :merging_user, :offending_identities

    def initialize(provider, identity, current_user = nil)
      @provider = provider
      @identity = identity
      @current_user = current_user
      @account_linker = AccountLinker.new(@identity, @current_user)
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
      (@account_linker || AccountLinker.new(@identity, @current_user)).determine_state.link
    end

  end
end
