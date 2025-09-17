TeachShare  Educational Content Marketplace Smart Contract

TeachShare is a decentralized marketplace built on the Stacks blockchain that enables teachers to monetize their educational content through smart contracts with automatic royalty distribution.

 Overview

This smart contract provides a trustless platform where educators can:
 List educational materials with custom pricing
 Receive automatic royalty payments
 Maintain ownership and control of their content
 Withdraw earnings at any time

 Features

 For Teachers
 Content Listing: Create listings for educational materials with custom titles, descriptions, and pricing
 Royalty Management: Set custom royalty percentages for ongoing earnings
 Earnings Tracking: Realtime tracking of total earnings and sales
 Content Control: Activate or deactivate content listings as needed
 Instant Withdrawals: Withdraw accumulated earnings at any time

 For Students/Buyers
 Secure Purchases: Purchase educational content with STX tokens
 Ownership Verification: Permanent record of content purchases
 Access Control: Only purchased content is accessible

 Platform Features
 Automatic Distribution: Smart contract handles all payment processing
 Low Platform Fees: Default 5% platform fee (configurable)
 Transparent Transactions: All transactions recorded on blockchain
 Gas Optimized: Efficient contract design for low transaction costs


Educational Content

 contentid: Unique identifier
 teacher: Content creator's principal
 title: Content title (max 100 characters)
 description: Content description (max 500 characters)
 price: Price in microSTX
 royaltypercentage: Royalty percentage (0100)
 totalsales: Number of sales
 isactive: Content availability status


 Purchase Records

 buyer: Purchaser's principal
 contentid: Purchased content ID
 purchasedat: Block height of purchase
 pricepaid: Amount paid in microSTX


 Error Codes

 u100: Owner only operation
 u101: Content not found
 u102: Unauthorized access
 u103: Insufficient funds
 u104: Already exists
 u105: Invalid price


 Deployment

1. Install Clarinet CLI
2. Clone this repository
3. Run clarinet check to verify contract
4. Deploy using clarinet deploy


 Testing

Run the test suite:
shellscript
clarinet test


 Security Considerations

 All earnings are held in the contract until withdrawal
 Only content owners can modify their listings
 Platform fees are configurable by contract owner only
 Purchase records are immutable once created


 License

MIT License  see LICENSE file for details

 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run clarinet check to ensure no errors
5. Submit a pull request


 Support

For questions or support, please open an issue in the GitHub repository.
