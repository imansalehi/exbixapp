class APIURLConstants {
  static const baseUrl = "https://imanpnl.exbix.com";

  ///End Urls : POST
  static const signIn = "/api/sign-in";
  static const signUp = "/api/sign-up";
  static const socialSignUpLogin = "/api/social-sign-login";
  static const verifyEmail = "/api/verify-email";
  static const g2FAVerify = "/api/g2f-verify";
  static const forgotPassword = "/api/forgot-password";
  static const resetPassword = "/api/reset-password";
  static const changePassword = "/api/change-password";
  static const logoutApp = "/api/log-out-app";
  static const walletNetworkAddress = "/api/get-wallet-network-address";
  static const walletWithdrawalProcess = "/api/wallet-withdrawal-process";
  static const preWithdrawalProcess = "/api/pre-withdrawal-process";
  static const swapCoinApp = "/api/swap-coin-app";
  static const updateProfile = "/api/update-profile";
  static const sendPhoneVerificationSms = "/api/send-phone-verification-sms";
  static const phoneVerify = "/api/phone-verify";
  static const google2faSetup = "/api/google2fa-setup";
  static const updateCurrency = "/api/update-currency";
  static const languageSetup = "/api/language-setup";
  static const uploadNID = "/api/upload-nid";
  static const uploadPassport = "/api/upload-passport";
  static const uploadDrivingLicence = "/api/upload-driving-licence";
  static const uploadVoterCard = "/api/upload-voter-card";
  static const notificationSeen = "/api/notification-seen";
  static const sellLimitApp = "/api/sell-limit-app";
  static const buyLimitApp = "/api/buy-limit-app";
  static const buyMarketApp = "/api/buy-market-app";
  static const sellMarketApp = "/api/sell-market-app";
  static const sellStopLimitApp = "/api/sell-stop-limit-app";
  static const buyStopLimitApp = "/api/buy-stop-limit-app";
  static const cancelOpenOrderApp = "/api/cancel-open-order-app";
  static const currencyDepositRate = "/api/get-currency-deposit-rate";
  static const convertCurrencyAmount = "/api/get-convert-currency-amount";
  static const paystackPaymentUrlGet = "/api/get-paystack-payment-url";
  static const currencyDepositProcess = "/api/currency-deposit-process";
  static const walletCurrencyDeposit = "/api/wallet-currency-deposit";
  static const walletCurrencyWithdraw = "/api/wallet-currency-withdraw";
  static const getFiatWithdrawalRate = "/api/get-fiat-withdrawal-rate";
  static const userBankSave = "/api/user-bank-save";
  static const userBankDelete = "/api/user-bank-delete";
  static const fiatWithdrawalProcess = "/api/fiat-withdrawal-process";
  static const thirdPartyKycVerified = "/api/third-party-kyc-verified";
  static const profileDeleteRequest = "/api/profile-delete-request";
  static const investmentCanceled = "/api/staking/investment-canceled";
  static const totalInvestmentBonus = "/api/staking/get-total-investment-bonus";
  static const investmentSubmit = "/api/staking/investment-submit";
  static const giftCardBuyCard = "/api/gift-card/buy-card";
  static const giftCardUpdateCard = "/api/gift-card/update-card";
  static const p2pWalletBalanceTransfer = "/api/p2p/transfer-wallet-balance";
  static const futureTradeWalletBalanceTransfer = "/api/future-trade/wallet-balance-transfer";
  static const futureTradeUpdateProfitLossLongShortOrder = "/api/future-trade/update-profit-loss-long-short-order";
  static const futureTradeCanceledLongShortOrder = "/api/future-trade/canceled-long-short-order";
  static const futureTradeCloseLongShortAllOrders = "/api/future-trade/close-long-short-all-orders";
  static const futureTradePrePlaceOrderData = "/api/future-trade/preplace-order-data";
  static const futureTradePlacedBuyOrder = "/api/future-trade/placed-buy-order";
  static const futureTradePlacedSellOrder = "/api/future-trade/placed-sell-order";
  static const futureTradePlaceCloseLongShortOrder = "/api/future-trade/close-long-short-order";
  static const evmCreateWallet = "evm/create-wallet";
  static const checkCoinTransaction = "/api/check-coin-transaction";

  ///End Urls : GET
  static const getAppDashboard = "/api/app-dashboard/";
  static const getExchangeChartDataApp = "/api/get-exchange-chart-data-app";
  static const getExchangeAllOrdersApp = "/api/get-exchange-all-orders-app";
  static const getExchangeMarketTradesApp = "/api/get-exchange-market-trades-app";
  static const getMyAllOrdersApp = "/api/get-my-all-orders-app";
  static const getMyTradesApp = "/api/get-my-trades-app";
  static const getProfile = "/api/profile";
  static const getWalletBalanceDetails = "/api/get-wallet-balance-details";
  static const getWalletList = "/api/wallet-list";
  static const getWalletTotalValue = "/api/wallet-total-value";
  static const getP2pWalletList = "/api/p2p/wallets";
  static const getWalletDeposit = "/api/wallet-deposit-";
  static const getWalletWithdrawal = "/api/wallet-withdrawal-";
  static const getCommonSettings = "/api/common-settings";
  static const getCommonSettingsWithLanding = "/api/common-landing-custom-settings";
  static const getWalletHistoryApp = "/api/wallet-history-app";
  static const getCoinConvertHistoryApp = "/api/coin-convert-history-app";
  static const getAllBuyOrdersHistoryApp = "/api/all-buy-orders-history-app";
  static const getAllSellOrdersHistoryApp = "/api/all-sell-orders-history-app";
  static const getAllTransactionHistoryApp = "/api/all-transaction-history-app";
  static const getCurrencyDepositHistory = "/api/currency-deposit-history";
  static const getWalletCurrencyDepositHistory = "/api/wallet-currency-deposit-history";
  static const getWalletCurrencyWithdrawHistory = "/api/wallet-currency-withdraw-history";
  static const getFiatWithdrawalHistory = "/api/fiat-withdrawal-history";
  static const getAllStopLimitOrdersApp = "/api/get-all-stop-limit-orders-app";
  static const getReferralHistory = "/api/referral-history";
  static const getRateApp = "/api/get-rate-app";
  static const getUserSetting = "/api/user-setting";
  static const getActivityList = "/api/activity-list";
  static const getKYCDetails = "/api/kyc-details";
  static const getUserKYCSettingsDetails = "/api/user-kyc-settings-details";
  static const getSetupGoogle2faLogin = "/api/setup-google2fa-login";
  static const getFaqList = "/api/faq-list";
  static const getNotifications = "/api/notifications";
  static const getReferralApp = "/api/referral-app";
  static const getCurrencyDeposit = "/api/currency-deposit";
  static const getFiatWithdrawal = "/api/fiat-withdrawal";
  static const getUserBankList = "/api/user-bank-list";
  static const getWalletCurrencyDeposit = "/api/wallet-currency-deposit";
  static const getWalletCurrencyWithdraw = "/api/wallet-currency-withdraw";
  static const getMarketOverviewCoinStatisticList = "/api/market-overview-coin-statistic-list";
  static const getMarketOverviewTopCoinList = "/api/market-overview-top-coin-list";
  static const getCurrencyList = "/api/currency-list";
  static const getCoinSwapApp = "/api/coin-swap-app";
  static const getLatestBlogList = "/api/latest-blog-list";
  static const getNetworksList = "/api/get-networks-list";
  static const getCoinNetwork = "/api/get-coin-network";

  static const getStakingOfferList = "/api/staking/offer-list";
  static const getStakingOfferDetails = "/api/staking/offer-list-details";
  static const getStakingInvestmentList = "/api/staking/investment-list";
  static const getStakingInvestmentStatistics = "/api/staking/investment-statistics";
  static const getStakingInvestmentPaymentList = "/api/staking/investment-get-payment-list";
  static const getStakingLandingDetails = "/api/staking/landing-details";

  static const getGiftCardMainPage = "/api/gift-card/gift-card-main-page";
  static const getGiftCardCheck = "/api/gift-card/check-card";
  static const getGiftCardRedeemCode = "/api/gift-card/get-redeem-code";
  static const getGiftCardThemeData = "/api/gift-card/gift-card-themes-page";
  static const getGiftCardThemes = "/api/gift-card/get-gift-card-themes";
  static const getGiftCardMyPageData = "/api/gift-card/my-gift-card-page";
  static const getGiftCardMyCardList = "/api/gift-card/my-gift-card-list";
  static const getGiftCardBuyData = "/api/gift-card/buy-card-page-data";
  static const getGiftCardWalletData = "/api/gift-card/gift-card-wallet-data";
  static const getGiftCardRedeem = "/api/gift-card/redeem-card";
  static const getGiftCardAdd = "/api/gift-card/add-gift-card";
  static const getGiftCardSend = "/api/gift-card/send-gift-card";

  static const getFutureTradeWalletList = "/api/future-trade/wallet-list";
  static const getFutureTradeExchangeMarketDetail = "/api/future-trade/get-exchange-market-details-app";
  static const getFutureTradeAppDashboard = "/api/future-trade/app-dashboard/";
  static const getFutureTradeLongShortPositionOrderList = "/api/future-trade/get-long-short-position-order-list";
  static const getFutureTradeLongShortOrderHistory = "/api/future-trade/get-long-short-order-history";
  static const getFutureTradeLongShortOpenOrderList = "/api/future-trade/get-long-short-open-order-list";
  static const getFutureTradeLongShortTransactionHistory = "/api/future-trade/get-long-short-transaction-history";
  static const getFutureTradeLongShortTradeHistory = "/api/future-trade/get-long-short-trade-history";
  static const getFutureTradeMyAllOrdersApp = "/api/future-trade/get-my-all-orders-app";
  static const getFutureTradeMyTradesApp = "/api/future-trade/get-my-trades-app";
  static const getFutureTradeExchangeMarketTradesApp = "/api/future-trade/get-exchange-market-trades-app";
  static const getFutureTradeTakeProfitStopLossDetails = "/api/future-trade/get-tp-sl-details-";

  static const getBlogNewsSettings = "/api/blog-news/settings";
  static const getBlogListType = "/api/blog/get";
  static const getBlogCategory = "/api/blog/category";
  static const getBlogSearch = "/api/blog/search";
  static const getBlogDetails = "/api/blog/blog-details";
  static const getNewsListType = "/api/news/get";
  static const getNewsCategory = "/api/news/category";
  static const getNewsDetails = "/api/news/news-details";

}

class APIKeyConstants {
  static const firstName = "first_name";
  static const lastName = "last_name";
  static const nickName = "nickname";
  static const email = "email";
  static const password = "password";
  static const confirmPassword = "password_confirmation";
  static const oldPassword = "old_password";
  static const accessToken = "access_token";
  static const accessTokenEvm = "evm_access_token";
  static const accessType = "access_type";
  static const userId = "user_id";
  static const user = "user";
  static const refreshToken = "refreshToken";
  static const gRecaptchaResponse = "g-recaptcha-response";
  static const recaptcha = "recapcha";
  static const score = "score";
  static const expireAt = "expireAt";
  static const phone = "phone";
  static const name = "name";
  static const title = "title";
  static const status = "status";
  static const image = "image";
  static const id = "id";
  static const ids = "ids";
  static const updatedAt = "updated_at";
  static const createdAt = "created_at";
  static const avatar = "avatar";
  static const isEmailVerified = "isEmailVerified";
  static const walletAddress = "walletAddress";
  static const first = "first";
  static const paginateNumber = "paginateNumber";
  static const currentPassword = "current_password";
  static const country = "country";
  static const gender = "gender";
  static const photo = "photo";
  static const verificationType = "verification_type";
  static const frontImage = "front_image";
  static const backImage = "back_image";
  static const fileTwo = "file_two";
  static const fileThree = "file_three";
  static const fileSelfie = "file_selfie";
  static const accept = "Accept";
  static const authorization = "Authorization";
  static const page = "page";
  static const perPage = "per_page";
  static const limit = "limit";
  static const type = "type";
  static const language = "language";
  static const verifyCode = "verify_code";
  static const code = "code";
  static const token = "token";
  static const url = "url";
  static const remove = "remove";
  static const search = "search";
  static const google2factSecret = "google2fa_secret";
  static const g2fEnabled = "g2f_enabled";
  static const userApiSecret = "userapisecret";
  static const evmApiSecret = "evmapisecret";
  static const userAgent = "User-Agent";
  static const lang = "lang";
  static const dashboardType = "dashboard_type";
  static const orderType = "order_type";
  static const baseCoinId = "base_coin_id";
  static const tradeCoinId = "trade_coin_id";
  static const orders = "orders";
  static const transactions = "transactions";
  static const wallets = "wallets";
  static const wallet = "wallet";
  static const walletType = "wallet_type";
  static const address = "address";
  static const amount = "amount";
  static const currency = "currency";
  static const currencyType = "currency_type";
  static const cryptoType = "crypto_type";
  static const price = "price";
  static const stop = "stop";
  static const total = "total";
  static const columnName = "column_name";
  static const orderBy = "order_by";
  static const success = "success";
  static const message = "message";
  static const emailVerified = "email_verified";
  static const time = "time";
  static const data = "data";
  static const walletId = "wallet_id";
  static const fromWalletId = "from_wallet_id";
  static const paymentMethodId = "payment_method_id";
  static const bankId = "bank_id";
  static const bankReceipt = "bank_receipt";
  static const networkType = "network_type";
  static const networkId = "network_id";
  static const network = "network";
  static const networks = "networks";
  static const fromCoinId = "from_coin_id";
  static const fromCoinType = "from_coin_type";
  static const toCoinId = "to_coin_id";
  static const toCoinType = "to_coin_type";
  static const convertRate = "convert_rate";
  static const rate = "rate";
  static const note = "note";
  static const setup = "setup";
  static const google2faSecret = "google2fa_secret";
  static const faqTypeId = "faq_type_id";
  static const calculatedAmount = "calculated_amount";
  static const convertedAmount = "converted_amount";
  static const stripeToken = "stripe_token";
  static const paypalToken = "paypal_token";
  static const transactionId = "transaction_id";
  static const interval = "interval";
  static const activityLog = "activityLog";
  static const inquiryId = "inquiry_id";
  static const deleteRequestReason = "delete_request_reason";
  static const uid = "uid";
  static const autoRenewStatus = "auto_renew_status";
  static const totalBonus = "total_bonus";
  static const commonSettings = "common_settings";
  static const landingSettings = "landing_settings";
  static const card = "card";
  static const banner = "banner";
  static const bannerId = "banner_id";
  static const cardUid = "card_uid";
  static const redeemCode = "redeem_code";
  static const coinType = "coin_type";
  static const lock = "lock";
  static const bulk = "bulk";
  static const quantity = "quantity";
  static const from = "from";
  static const sendBy = "send_by";
  static const toEmail = "to_email";
  static const toPhone = "to_phone";
  static const transferFrom = "transfer_from";
  static const coinPairId = "coin_pair_id";
  static const orderUid = "order_uid";
  static const orderId = "order_id";
  static const takeProfit = "take_profit";
  static const stopLoss = "stop_loss";
  static const side = "side";
  static const tradeType = "trade_type";
  static const marginMode = "margin_mode";
  static const amountType = "amount_type";
  static const stopPrice = "stop_price";
  static const leverageAmount = "leverage_amount";
  static const coinPairDetails = "coin_pair_details";
  static const paymentMethodType = "payment_method_type";
  static const paymentInfo = "payment_info";
  static const coin = "coin";
  static const baseType = "base_type";
  static const coinPaymentNetworks = "coin_payment_networks";
  static const category = "category";
  static const subCategory = "subcategory";
  static const value = "value";
  static const memo = "memo";
  static const coinId = "coin_id";
  static const trxId = "trx_id";
  static const loginType = "login_type";
  static const userID = "userID";


  static const vAccept = "application/json";
  static const vProfilePhotoPath = "";
  static const vBearer = "Bearer";
  static const vOrderDESC = "desc";
  static const vOrderASC = "asc";
}

class SocketConstants {
  static const baseUrl = "wss://imanpnl.exbix.com/app/test";

  static const channelNewMessage = "New-Message-";
  static const channelOrderStatus = "Order-Status-";
  static const eventOrderStatus = "OrderStatus";
  static const eventConversation = "Conversation";

  static const channelNotification = "notification_";
  static const channelDashboard = "dashboard-";
  static const channelTradeInfo = "trade-info-";
  static const channelTradeHistory = "trade-history-";
  static const channelOrderPlace = "order_place_";
  static const channelFutureTrade = "future-trade-";
  static const channelFutureTradeGetExchangeMarketDetailsData = "future-trade-get-exchange-market-details-data";
  static const channelMarketOverviewCoinStatisticListData = "market-overview-coin-statistic-list-data";
  static const channelMarketOverviewTopCoinListData = "market-overview-top-coin-list-data";

  static const eventNotification = "notification";
  static const eventOrderPlace = "order_place";
  static const eventProcess = "process";
  static const eventOrderRemove = "order_removed";
  static const eventFutureTradeData = "future-trade-data";
  static const eventMarketDetailsData = "market-details-data";
  static const eventMarketOverviewCoinStatisticList = "market-overview-coin-statistic-list";
  static const eventMarketOverviewTopCoinList = "market-overview-top-coin-list";
}

class URLConstants {
  static const website = "https://exbix.com";
  static const referralLink = "$website/signup?";
  static const blogShare = "$website/blog/";
  static const fbReferral = "https://www.facebook.com/sharer/sharer.php?u=";
  static const twitterReferral = "https://www.twitter.com/share?url=";
}

class ErrorConstants {
  static const unauthorized = "Unauthorized";
}
