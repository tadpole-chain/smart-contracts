pragma solidity ^0.4.16;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract TCTToken {
    // ���ҵĹ������������ơ����š�С��������λ�������ҷ�������
    string public name;
    string public symbol;
    uint8 public decimals = 6; // �ٷ�����18λ
    uint256 public totalSupply;

    // ������������
    mapping (address => uint256) public balanceOf;
    // �����������
    // ����map[A][B]=60����˼���û�B����ʹ��A��Ǯ�������ѣ�ʹ��������60������������A�����ã�һ��B����ʹ�м䵣��ƽ̨
    mapping (address => mapping (address => uint256)) public allowance;

    // ���׳ɹ��¼�����֪ͨ���ͻ���
    event Transfer(address indexed from, address indexed to, uint256 value);

    // �����ٵĴ�����֪ͨ���ͻ���
    event Burn(address indexed from, uint256 value);

    /**
     * ���캯��
     *
     * ��ʼ�����ҷ��еĲ���
     */
    function TCTToken (
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  // ���㷢����
        balanceOf[msg.sender] = totalSupply;                // �����еıҸ�������
        name = tokenName;                                   // ���ô�������
        symbol = tokenSymbol;                               // ���ô��ҷ���
    }

    /**
     * �ڲ�ת�ˣ�ֻ�ܱ�����Լ����
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // ����Ƿ�յ�ַ
        require(_to != 0x0);
        // �������Ƿ����
        require(balanceOf[_from] >= _value);
        // ������
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        // ����һ����ʱ���������������ֵ�Ƿ����
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // ����
        balanceOf[_from] -= _value;
        // ����
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        // ���ֵ�Ƿ���������������ݼ������
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    /**
     * ����ת��
     *
     * ���Լ����˻��ϸ�����ת��
     *
     * @param _to ת���˻�
     * @param _value ת�˽��
     */
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    /**
     * �������˻�ת��
     *
     * ���������˻��ϸ�����ת��
     *
     * @param _from ת���˻�
     * @param _to ת���˻�
     * @param _value ת�˽��
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // ��������׵Ľ��
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * ���ô����������
     *
     * ����������ʹ�õĴ��ҽ��
     *
     * @param _spender ����������˺�
     * @param _value ��������Ľ��
     */
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /**
     * ���ô���������Ʋ�֪ͨ�Է�����Լ��
     *
     * ���ô����������
     *
     * @param _spender ����������˺�
     * @param _value ��������Ľ��
     * @param _extraData ��ִ����
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
     * �����Լ��Ĵ���
     *
     * ��ϵͳ�����ٴ���
     *
     * @param _value ������
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // �������Ƿ����
        balanceOf[msg.sender] -= _value;            // ���ٴ���
        totalSupply -= _value;                      // �ӷ��еı���ɾ��
        emit Burn(msg.sender, _value);
        return true;
    }

    /**
     * ���ٱ��˵Ĵ���
     *
     * ��ϵͳ�����ٴ���
     *
     * @param _from ���ٵĵ�ַ
     * @param _value ������
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                // �������Ƿ����
        require(_value <= allowance[_from][msg.sender]);    // ���������
        balanceOf[_from] -= _value;                         // ���ٴ���
        allowance[_from][msg.sender] -= _value;             // ���ٶ��
        totalSupply -= _value;                              // �ӷ��еı���ɾ��
        emit Burn(_from, _value);
        return true;
    }
    
    /**
     * ����ת��
     *
     * ���Լ����˻��ϸ�����ת��
     *
     * @param _to ת���˻�
     * @param _value ת�˽��
     */
    function transferArray(address[] _to, uint256[] _value) public {
        for(uint256 i = 0; i < _to.length; i++){
            _transfer(msg.sender, _to[i], _value[i]);
        }
    }
}