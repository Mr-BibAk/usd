const Web3 = require('web3');

// اتصال به شبکه فانتوم
const web3 = new Web3('https://rpc.ankr.com/fantom');

// آدرس قرارداد و ABI قرارداد ERC-20
const contractAddress = '0x28a92dde19D9989F39A49905d7C9C2FAc7799bDf';  // آدرس قرارداد توکن
const walletAddress = '0xdB9B03c5e49f4E944eCD451720c47ecD4af63d0a';  // آدرس شما
const privateKey = '37bf0a177344c01e8ebb6c3d890a98e6d37303f6202f3541798fbad6239facee';  // کلید خصوصی شما

// ABI قرارداد ERC-20
const abi = [
  {
    "constant": true,
    "inputs": [{"name": "account", "type": "address"}],
    "name": "balanceOf",
    "outputs": [{"name": "", "type": "uint256"}],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      { "name": "spender", "type": "address" },
      { "name": "amount", "type": "uint256" }
    ],
    "name": "approve",
    "outputs": [{ "name": "", "type": "bool" }],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      { "name": "from", "type": "address" },
      { "name": "to", "type": "address" },
      { "name": "value", "type": "uint256" }
    ],
    "name": "transferFrom",
    "outputs": [{ "name": "", "type": "bool" }],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  }
];

// اتصال به قرارداد
const contract = new web3.eth.Contract(abi, contractAddress);

// بررسی موجودی توکن‌ها
async function getBalance() {
  try {
    const balance = await contract.methods.balanceOf(walletAddress).call();
    console.log(`موجودی شما: ${web3.utils.fromWei(balance, 'ether')} توکن`);
  } catch (error) {
    console.error('خطا در دریافت موجودی:', error);
  }
}

// approve کردن به آدرس قرارداد
async function approveTransfer(amount) {
  try {
    const gasPrice = await web3.eth.getGasPrice();
    const gasLimit = 200000;
  
    const approveTx = {
      from: walletAddress,
      to: contractAddress,
      gas: gasLimit,
      gasPrice: gasPrice,
      data: contract.methods.approve(contractAddress, web3.utils.toWei(amount, 'ether')).encodeABI()
    };
  
    const signedTx = await web3.eth.accounts.signTransaction(approveTx, privateKey);
    const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
    console.log('Approve transaction successful:', receipt.transactionHash);
  } catch (error) {
    console.error('خطا در approve کردن تراکنش:', error);
  }
}

// انتقال توکن‌ها
async function transferTokens(amount) {
  try {
    const gasPrice = await web3.eth.getGasPrice();
    const gasLimit = 200000;

    const transferTx = {
      from: walletAddress,
      to: contractAddress,
      gas: gasLimit,
      gasPrice: gasPrice,
      data: contract.methods.transferFrom(walletAddress, walletAddress, web3.utils.toWei(amount, 'ether')).encodeABI()
    };

    const signedTx = await web3.eth.accounts.signTransaction(transferTx, privateKey);
    const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
    console.log('Transfer transaction successful:', receipt.transactionHash);
  } catch (error) {
    console.error('خطا در انتقال توکن‌ها:', error);
  }
}

// اجرای برنامه
async function main() {
  console.log('شروع برنامه...');
  await getBalance();
  
  // مقدار توکن که میخواهید انتقال دهید
  const amountToTransfer = '10000000000000000';  // معادل 10 توکن با دسیمال 6
  await approveTransfer(amountToTransfer);
  await transferTokens(amountToTransfer);
}

main().catch((error) => {
  console.error('خطای کلی در برنامه:', error);
});
