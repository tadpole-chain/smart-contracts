pragma solidity ^0.4.16;

contract TCTDatas {
    
    // 用户信息数据
    mapping (address => string) public userDatas;
    
    // 在线时长统计数据
    string[] public durationDatas;
    // 在线时长的索引数据
    mapping (address => uint256[]) public durationIndex;
    
    // TCT结算记录数据
    string[] public profitDatas;
    // TCT结算记录的索引数据
    mapping (address => uint256[]) public profitIndex;
    
    // 排行榜数据
    string public rankingDatas;
    
    // 本合约的创建者
    address public creator;
    
    // 可以调用本合约写入方法的合约地址
    address public version;

    /**
     * 构造函数
     *
     * 初始化控制权限参数
     */
    function TCTDatas () public {
        creator = msg.sender;
        version= msg.sender;
    }
    
    /**
     * 更新智能合约版本
     * 
     * @param _version 新的合约版本地址
     */
    function changeVersion(address _version) public {
        require(creator == msg.sender);
        version = _version;
    }
    
    /**
     * 更换智能合约的管理员
     * 
     * @param _creator 新的管理员
     */
    function changeCreator(address _creator) public {
        require(creator == msg.sender);
        creator = _creator;
    }
    
    /**
     * 检测调用合约的版本号
     * 
     */
    modifier platform() {
        // 调用合约的是最新版本，或者未更新过版本
        require(version == msg.sender);
        _;
    }
    
    /**
     * 设置用户信息
     * 
     * @param _adr 用户ID
     * @param _sum 每个用户数据占用的字节数组
     * @param _value 用户数据
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
     * 保存用户在线时长的数据
     * 
     * @param _user 用户地址
     * @param _game 游戏地址
     * @param _sum 每个用户数据占用的字节数组
     * @param _value 用户数据
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
     * 保存用户收益的数据
     * 
     * @param _user 用户地址
     * @param _game 游戏地址
     * @param _sum 每个用户数据占用的字节数组
     * @param _value 用户数据
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
     * 保存单个用户收益的数据
     * 
     * @param _user 用户地址
     * @param _game 游戏地址
     * @param _value 用户数据
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
     * 保存单个用户在线时长的数据
     * 
     * @param _user 用户地址
     * @param _game 游戏地址
     * @param _value 用户数据
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
     * 保存排行榜数据
     * 
     * @param _datas 排行榜数据
     */
    function putRankingDatas(string _datas) platform public {
        rankingDatas = _datas;
    }
    
    /**
     * 读取用户收益的数据
     * 
     * @param _adr 用户地址
     * @param _offset 起始位置
     * @param _limit 每页个数
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
     * 读取用户在线时长的数据
     * 
     * @param _adr 用户地址
     * @param _offset 起始位置
     * @param _limit 每页个数
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