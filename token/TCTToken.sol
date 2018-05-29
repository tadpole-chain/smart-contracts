pragma solidity ^0.4.16;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract TCTToken {
    // 代币的公共变量：名称、代号、小数点后面的位数、代币发行总量
    string public name;
    string public symbol;
    uint8 public decimals = 6; // 官方建议18位
    uint256 public totalSupply;

    // 代币余额的数据
    mapping (address => uint256) public balanceOf;
    // 代付金额限制
    // 比如map[A][B]=60，意思是用户B可以使用A的钱进行消费，使用上限是60，此条数据由A来设置，一般B可以使中间担保平台
    mapping (address => mapping (address => uint256)) public allowance;

    // 交易成功事件，会通知给客户端
    event Transfer(address indexed from, address indexed to, uint256 value);

    // 将销毁的代币量通知给客户端
    event Burn(address indexed from, uint256 value);

    /**
     * 构造函数
     *
     * 初始化代币发行的参数
     */
    function TCTToken (
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  // 计算发行量
        balanceOf[msg.sender] = totalSupply;                // 将发行的币给创建者
        name = tokenName;                                   // 设置代币名称
        symbol = tokenSymbol;                               // 设置代币符号
    }

    /**
     * 内部转账，只能被本合约调用
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // 检测是否空地址
        require(_to != 0x0);
        // 检测余额是否充足
        require(balanceOf[_from] >= _value);
        // 检测溢出
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        // 保存一个临时变量，用于最后检测值是否溢出
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // 出账
        balanceOf[_from] -= _value;
        // 入账
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        // 检测值是否溢出，或者有数据计算错误
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    /**
     * 代币转账
     *
     * 从自己的账户上给别人转账
     *
     * @param _to 转入账户
     * @param _value 转账金额
     */
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    /**
     * 从其他账户转账
     *
     * 从其他的账户上给别人转账
     *
     * @param _from 转出账户
     * @param _to 转入账户
     * @param _value 转账金额
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // 检查允许交易的金额
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * 设置代付金额限制
     *
     * 允许消费者使用的代币金额
     *
     * @param _spender 允许代付的账号
     * @param _value 允许代付的金额
     */
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /**
     * 设置代付金额限制并通知对方（合约）
     *
     * 设置代付金额限制
     *
     * @param _spender 允许代付的账号
     * @param _value 允许代付的金额
     * @param _extraData 回执数据
     */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    /**
     * 销毁自己的代币
     *
     * 从系统中销毁代币
     *
     * @param _value 销毁量
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // 检测余额是否充足
        balanceOf[msg.sender] -= _value;            // 销毁代币
        totalSupply -= _value;                      // 从发行的币中删除
        emit Burn(msg.sender, _value);
        return true;
    }

    /**
     * 销毁别人的代币
     *
     * 从系统中销毁代币
     *
     * @param _from 销毁的地址
     * @param _value 销毁量
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                // 检测余额是否充足
        require(_value <= allowance[_from][msg.sender]);    // 检测代付额度
        balanceOf[_from] -= _value;                         // 销毁代币
        allowance[_from][msg.sender] -= _value;             // 销毁额度
        totalSupply -= _value;                              // 从发行的币中删除
        emit Burn(_from, _value);
        return true;
    }
    
    /**
     * 批量转账
     *
     * 从自己的账户上给别人转账
     *
     * @param _to 转入账户
     * @param _value 转账金额
     */
    function transferArray(address[] _to, uint256[] _value) public {
        for(uint256 i = 0; i < _to.length; i++){
            _transfer(msg.sender, _to[i], _value[i]);
        }
    }
}