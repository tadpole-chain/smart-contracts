pragma solidity ^0.4.16;

contract TCTDatas {
    
    // �û���Ϣ����
    mapping (address => string) public userDatas;
    
    // ����ʱ��ͳ������
    string[] public durationDatas;
    // ����ʱ������������
    mapping (address => uint256[]) public durationIndex;
    
    // TCT�����¼����
    string[] public profitDatas;
    // TCT�����¼����������
    mapping (address => uint256[]) public profitIndex;
    
    // ���а�����
    string public rankingDatas;
    
    // ����Լ�Ĵ�����
    address public creator;
    
    // ���Ե��ñ���Լд�뷽���ĺ�Լ��ַ
    address public version;

    /**
     * ���캯��
     *
     * ��ʼ������Ȩ�޲���
     */
    function TCTDatas () public {
        creator = msg.sender;
        version= msg.sender;
    }
    
    /**
     * �������ܺ�Լ�汾
     * 
     * @param _version �µĺ�Լ�汾��ַ
     */
    function changeVersion(address _version) public {
        require(creator == msg.sender);
        version = _version;
    }
    
    /**
     * �������ܺ�Լ�Ĺ���Ա
     * 
     * @param _creator �µĹ���Ա
     */
    function changeCreator(address _creator) public {
        require(creator == msg.sender);
        creator = _creator;
    }
    
    /**
     * �����ú�Լ�İ汾��
     * 
     */
    modifier platform() {
        // ���ú�Լ�������°汾������δ���¹��汾
        require(version == msg.sender);
        _;
    }
    
    /**
     * �����û���Ϣ
     * 
     * @param _adr �û�ID
     * @param _sum ÿ���û�����ռ�õ��ֽ�����
     * @param _value �û�����
     */
    function setUserDatas(address[] _adr, uint16[] _sum, byte[] _value) platform public {
        require(_adr.length == _sum.length);
        uint16 count = 0;
        for(uint16 i = 0; i < _adr.length; i++){
            string memory ret = new string(_sum[i]);
            bytes memory bret = bytes(ret);
            for (uint16 k = 0; k < _sum[i]; k++) bret[k] = _value[count + k];
            userDatas[_adr[i]] = string(ret);
            count += _sum[i];
        }
    }
    
    /**
     * �����û�����ʱ��������
     * 
     * @param _user �û���ַ
     * @param _game ��Ϸ��ַ
     * @param _sum ÿ���û�����ռ�õ��ֽ�����
     * @param _value �û�����
     */
    function setDurationDatas(address[] _user, address[] _game, uint16[] _sum, byte[] _value) platform public {
        require(_user.length == _sum.length);
        uint16 count = 0;
        for(uint16 i = 0; i < _user.length; i++){
            string memory ret = new string(_sum[i]);
            bytes memory bret = bytes(ret);
            for (uint16 k = 0; k < _sum[i]; k++) bret[k] = _value[count + k];
            durationDatas.push(string(ret));
            if(_user[i] != 0x0)
                durationIndex[_user[i]].push(durationDatas.length - 1);
            if(_game[i] != 0x0)
                durationIndex[_game[i]].push(durationDatas.length - 1);
            count += _sum[i];
        }
    }
    
    /**
     * �����û����������
     * 
     * @param _user �û���ַ
     * @param _game ��Ϸ��ַ
     * @param _sum ÿ���û�����ռ�õ��ֽ�����
     * @param _value �û�����
     */
    function setProfitDatas(address[] _user, address[] _game, uint16[] _sum, byte[] _value) platform public {
        require(_user.length == _sum.length);
        uint16 count = 0;
        for(uint16 i = 0; i < _user.length; i++){
            string memory ret = new string(_sum[i]);
            bytes memory bret = bytes(ret);
            for (uint16 k = 0; k < _sum[i]; k++) bret[k] = _value[count + k];
            profitDatas.push(string(ret));
            if(_user[i] != 0x0)
                profitIndex[_user[i]].push(profitDatas.length - 1);
            if(_game[i] != 0x0)
                profitIndex[_game[i]].push(profitDatas.length - 1);
            count += _sum[i];
        }
    }
    
    /**
     * ���浥���û����������
     * 
     * @param _user �û���ַ
     * @param _game ��Ϸ��ַ
     * @param _value �û�����
     */
    function putProfitData(address _user, address _game, byte[] _value) platform public {
        require(_user != 0x0);
        string memory ret = new string(_value.length);
        bytes memory bret = bytes(ret);
        for (uint16 k = 0; k < _value.length; k++) bret[k] = _value[k];
        profitDatas.push(string(ret));
        if(_user != 0x0)
            profitIndex[_user].push(profitDatas.length - 1);
        if(_game != 0x0)
            profitIndex[_game].push(profitDatas.length - 1);
    }
    
    /**
     * ���浥���û�����ʱ��������
     * 
     * @param _user �û���ַ
     * @param _game ��Ϸ��ַ
     * @param _value �û�����
     */
    function putDurationData(address _user, address _game, byte[] _value) platform public {
        require(_user != 0x0);
        string memory ret = new string(_value.length);
        bytes memory bret = bytes(ret);
        for (uint16 k = 0; k < _value.length; k++) bret[k] = _value[k];
        durationDatas.push(string(ret));
        if(_user != 0x0)
            durationIndex[_user].push(durationDatas.length - 1);
        if(_game != 0x0)
            durationIndex[_game].push(durationDatas.length - 1);
    }
    
    /**
     * �������а�����
     * 
     * @param _datas ���а�����
     */
    function putRankingDatas(string _datas) platform public {
        rankingDatas = _datas;
    }
    
    /**
     * ��ȡ�û����������
     * 
     * @param _adr �û���ַ
     * @param _offset ��ʼλ��
     * @param _limit ÿҳ����
     */
    function getProfitDatas(address _adr, uint256 _offset, uint256 _limit) public constant returns (uint256 total, string result) {
        if(_offset < 0){
            _offset = 0;
        }
        if(_limit <= 0){
            _limit = 10;
        }
        if(_adr == 0x0) {
            if(profitDatas.length == 0 || profitDatas.length < _offset){
                return (profitDatas.length, "[]");
            }
            uint256 sum = _limit;
            uint256 s = profitDatas.length;
            if(profitDatas.length - _offset < _limit){
                sum = profitDatas.length - _offset;
            }
            result = "[";
            for(uint256 i = _offset; i < _offset + sum; i++){
                if(i == _offset && i == _offset + sum - 1){
                    result = strConcat("[", profitDatas[s - 1 - i]);
                    result = strConcat(result, "]");
                } else if(i == _offset){
                    result = strConcat("[", profitDatas[s - 1 - i]);
                } else if(i == _offset + sum - 1){
                    result = strConcat(result, ",");
                    result = strConcat(result, profitDatas[s - 1 - i]);
                    result = strConcat(result, "]");
                } else {
                    result = strConcat(result, ",");
                    result = strConcat(result, profitDatas[s - 1 - i]);
                }
            }
            return (s, result);
        } else {
            if(profitIndex[_adr].length == 0 || profitIndex[_adr].length < _offset){
                return (profitIndex[_adr].length, "[]");
            }
            uint256 sum2 = _limit;
            uint256 s2 = profitIndex[_adr].length;
            if(profitIndex[_adr].length - _offset < _limit){
                sum2 = profitIndex[_adr].length - _offset;
            }
            for(uint256 k = _offset; k < _offset + sum2; k++){
                if(k == _offset && k == _offset + sum2 - 1){
                    result = strConcat("[", profitDatas[profitIndex[_adr][s2 - 1 - k]]);
                    result = strConcat(result, "]");
                } else if(k == _offset){
                    result = strConcat("[", profitDatas[profitIndex[_adr][s2 - 1 - k]]);
                } else if(k == _offset + sum2 - 1){
                    result = strConcat(result, ",");
                    result = strConcat(result, profitDatas[profitIndex[_adr][s2 - 1 - k]]);
                    result = strConcat(result, "]");
                } else {
                    result = strConcat(result, ",");
                    result = strConcat(result, profitDatas[profitIndex[_adr][s2 - 1 - k]]);
                }
            }
            return (s2, result);
        }
    }
    
    /**
     * ��ȡ�û�����ʱ��������
     * 
     * @param _adr �û���ַ
     * @param _offset ��ʼλ��
     * @param _limit ÿҳ����
     */
    function getDurationDatas(address _adr, uint256 _offset, uint256 _limit) public constant returns (uint256 total, string result) {
        if(_offset < 0){
            _offset = 0;
        }
        if(_limit <= 0){
            _limit = 10;
        }
        if(_adr == 0x0) {
            if(durationDatas.length == 0 || durationDatas.length < _offset){
                return (durationDatas.length, "[]");
            }
            uint256 sum = _limit;
            uint256 s = durationDatas.length;
            if(durationDatas.length - _offset < _limit){
                sum = durationDatas.length - _offset;
            }
            result = "[";
            for(uint256 i = _offset; i < _offset + sum; i++){
                if(i == _offset && i == _offset + sum - 1){
                    result = strConcat("[", durationDatas[s - 1 - i]);
                    result = strConcat(result, "]");
                } else if(i == _offset){
                    result = strConcat("[", durationDatas[s - 1 - i]);
                } else if(i == _offset + sum - 1){
                    result = strConcat(result, ",");
                    result = strConcat(result, durationDatas[s - 1 - i]);
                    result = strConcat(result, "]");
                } else {
                    result = strConcat(result, ",");
                    result = strConcat(result, durationDatas[s - 1 - i]);
                }
            }
            return (s, result);
        } else {
            if(durationIndex[_adr].length == 0 || durationIndex[_adr].length < _offset){
                return (durationIndex[_adr].length, "[]");
            }
            uint256 sum2 = _limit;
            uint256 s2 = durationIndex[_adr].length;
            if(durationIndex[_adr].length - _offset < _limit){
                sum2 = durationIndex[_adr].length - _offset;
            }
            for(uint256 k = _offset; k < _offset + sum2; k++){
                if(k == _offset && k == _offset + sum2 - 1){
                    result = strConcat("[", durationDatas[durationIndex[_adr][s2 - 1 - k]]);
                    result = strConcat(result, "]");
                } else if(k == _offset){
                    result = strConcat("[", durationDatas[durationIndex[_adr][s2 - 1 - k]]);
                } else if(k == _offset + sum2 - 1){
                    result = strConcat(result, ",");
                    result = strConcat(result, durationDatas[durationIndex[_adr][s2 - 1 - k]]);
                    result = strConcat(result, "]");
                } else {
                    result = strConcat(result, ",");
                    result = strConcat(result, durationDatas[durationIndex[_adr][s2 - 1 - k]]);
                }
            }
            return (s2, result);
        }
    }
    
    function strConcat(string _a, string _b) internal pure returns (string){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        string memory ret = new string(_ba.length + _bb.length);
        bytes memory bret = bytes(ret);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++)bret[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) bret[k++] = _bb[i];
        return string(ret);
   }
}