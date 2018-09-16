pragma solidity ^0.4.20;

contract SurvivalGame {
    
	mapping(address => uint) internal tokenBalance;
	mapping(address => uint) internal maxRecord;
	
	//vegetable
	struct Vegetable {
	    
	    uint grade;
        uint curCapacity;
	}

	mapping(address => Vegetable) internal vegetableMap;
    
	struct Gate {
	    
        uint people;
        uint monsterVitality;
        uint curVitality;
        uint grade;
	}
	
	mapping(address => Gate) internal gateMap;
	
	struct Facilities {
	    
        uint curCapacity;
        uint grade;
	}
    mapping(address => Facilities) internal houseMap;
	mapping(address => Facilities) internal warehouseMap;
	mapping(address => Facilities) internal woodenbucketMap;
	
	struct Castle {
	    
    	uint liveDay;
        uint rainProbability;
        uint actionPower;
        uint diePeople;
	}
	mapping(address => Castle) internal castleMap;
	
	struct  DayState {
	    
	    uint searchPeople;
	    uint diePeople;
	    uint survival;
	    bool isRain;
	}
	mapping(address => DayState) internal dayStateMap;
	//WildArea
    mapping(address => uint) peoples;
    uint256 randomNonce;
    
    modifier onlyLife() {
      require(isLife(msg.sender));
      _;
    }
    function SurvivalGame() public {
        
    }
    
    function playerGameState(address who) public view  returns(uint) {
        
        return tokenBalance[who];
    }
    
    function loginGame() public {
        
        if(tokenBalance[msg.sender] == 0 ) {
            
            tokenBalance[msg.sender] = 5;
            houseMap[msg.sender] = Facilities( 1, 1);
            gateMap[msg.sender] = Gate(0, 1, 10, 1);
            castleMap[msg.sender] = Castle(1, 10, 1, 0);
            
        }
    }
    
    function createPlayer() public {
        
        if(tokenBalance[msg.sender] == 5) {
           
            tokenBalance[msg.sender] = 1;
            woodenbucketMap[msg.sender] = Facilities( 5, 1);
            warehouseMap[msg.sender] = Facilities(10, 1);
            vegetableMap[msg.sender] = Vegetable(1,5);
            dayStateMap[msg.sender]= DayState(0,0, 0, false);
        }
    }
    
    function getDayState(address who) public view returns(bool, uint, uint, uint) {
        
        DayState storage day = dayStateMap[who];
        return (day.isRain, day.survival, day.diePeople, day.searchPeople);
    }
    
    function getActionPower(address who) public view returns (uint) {
        
        return castleMap[who].actionPower;
    }
    
    function getMaxLiveDay(address who) public view returns (uint) {
       
        return maxRecord[who];
    }
    
    function getLiveDay(address who) public view returns (uint) {
        
        return castleMap[who].liveDay;
    }
    
    function getVegetable(address who) public view returns(uint, uint) {
    
        Vegetable storage vege = vegetableMap[who];
        return (vege.curCapacity, getMaxVegetable(vege));
    }
    
    function getWater(address who) public view returns (uint, uint) {
         
        Facilities storage woodenbucket = woodenbucketMap[who];
        return (woodenbucket.curCapacity, getMaxWoodenbucket(woodenbucket));
    }
    
    function getRainProbability(address who) public view returns(uint) {
       
       return castleMap[who].rainProbability;
    }

    function getWooden(address who) public view returns(uint, uint) {
 
       Facilities storage warehouse = warehouseMap[who];
       return (warehouse.curCapacity, getMaxWarehouse(warehouse));
    }
    
    function getPopulation(address who) public view returns (uint, uint) {
    
       Facilities storage house = houseMap[who];
       Gate storage gate = gateMap[who];
       uint num = house.curCapacity + gate.people + peoples[who];
       return (num, getMaxHouse(house));
    }
    
    function getPeopleList(address who) public view returns (uint, uint, uint,uint) {
        
        Facilities storage house = houseMap[who];
        Castle storage castle = castleMap[who];
        Gate storage gate = gateMap[who];
        return (house.curCapacity,  castle.diePeople, gate.people,  peoples[who]);
    }
 
    function getGateMonsterVitality(address who) public view returns(uint) {

       return gateMap[who].monsterVitality;
    }
    
    function getResistance(address who) public view returns(uint, uint) {
        
        Gate storage gate = gateMap[who];
        return (gate.curVitality, getMaxGateVitality(gate));
    }
 
    function getGradeFacilities(address who) public view returns(uint, uint, uint, uint, uint) {

        Vegetable storage vege = vegetableMap[who];
        Facilities storage house = houseMap[who];
        Facilities storage warehouse = warehouseMap[who];
        Facilities storage woodenbucket = woodenbucketMap[who];
        Gate storage gate = gateMap[who];
        return (vege.grade, house.grade, warehouse.grade, woodenbucket.grade, gate.grade);
    } 
    
    // 1- vegetable 2- house 3- warehouse 4- woodenbucket 5- gate 
    function upGradeFacilities(uint256 index) public onlyLife {
        
        Facilities storage warehouse = warehouseMap[msg.sender];
        if(index == 1) {
            
            Vegetable storage vege = vegetableMap[msg.sender];
            uint needWooden = 2 + uint(vege.grade / 2);
            if(warehouse.curCapacity >= needWooden){
                
                warehouse.curCapacity -= needWooden;
                vege.grade += 1;
            }
        } else if(index == 2) {
            
            Facilities storage house = houseMap[msg.sender];
            uint houseNeedWooden = 5 + uint(house.grade/2);
            if(warehouse.curCapacity >= houseNeedWooden){
                
                warehouse.curCapacity -= houseNeedWooden;
                house.grade += 1;
            }
        } else if(index == 3) {
            
            uint wareNeedWooden = 5 + uint(warehouse.grade / 2);
            if(warehouse.curCapacity >= wareNeedWooden){
                
                warehouse.curCapacity -= wareNeedWooden;
                warehouse.grade += 1;
            }
        } else if(index == 4) {
            
            Facilities storage woodenbucket = woodenbucketMap[msg.sender];
            uint bucketNeedWooden = 3 + uint(woodenbucket.grade / 2);
            if(warehouse.curCapacity >= bucketNeedWooden){
                
                warehouse.curCapacity -= bucketNeedWooden;
                woodenbucket.grade += 1;
            }
        } else if(index == 5) {
            
            Gate storage gate = gateMap[msg.sender];
            uint gateNeedWooden = 2 + gate.grade;
            if(warehouse.curCapacity >= gateNeedWooden){
                
                warehouse.curCapacity -= gateNeedWooden;
                gate.grade += 1;
            }
        }
    }
    
    function searchRescue() public onlyLife returns(bool) {
    
       Facilities storage house = houseMap[msg.sender];
       Gate storage gate = gateMap[msg.sender];
       uint num = house.curCapacity + gate.people + peoples[msg.sender];
       uint limit = 100 - uint(num / 5) * 20;
       if(limit < 30) {
           limit = 30;
       }
       if(costActionPower(2) && isHappen(limit)) {

           house.curCapacity += 1;
           dayStateMap[msg.sender].searchPeople += 1;
           uint max = getMaxHouse(house);
           if(house.curCapacity > max) {
               house.curCapacity = max;
           }
           return true;
       }
       return false;
    }
  
    function prayRain() public onlyLife {
        
        Castle storage castle = castleMap[msg.sender];
        if(costActionPower(1)) {
                
           castle.rainProbability += 10;
        }
    }
    
    function repairGate() public onlyLife {

        Gate storage gate = gateMap[msg.sender];
        Facilities storage warehouse = warehouseMap[msg.sender];
        uint max =  getMaxGateVitality(gate);
        uint off = max - gate.curVitality;
        uint num = uint( off / 2);
        if(num > 10) {
            num = 10;
        }
        
        if(warehouse.curCapacity >= num) {
            
            if(off > 20) {
                off = 20;
            }
            
            warehouse.curCapacity -= num;
            gate.curVitality += off;
        }
    }
    
    function peopleGateStand(bool toStand) public onlyLife {

        Gate storage gate = gateMap[msg.sender];
        Facilities storage house = houseMap[msg.sender];
        if(toStand){
            if(house.curCapacity > 0 ) {
                
                house.curCapacity -= 1;
                gate.people += 1;
            }
        } else {
            if(gate.people > 0) {
                house.curCapacity += 1;
                uint num = getMaxHouse(house);
                if(num < house.curCapacity){
                    house.curCapacity = num;
                }
                gate.people -= 1;
            }
        }
    }
  
    function expatriatePeople() public onlyLife {

        Facilities storage house = houseMap[msg.sender];
        if(house.curCapacity > 0) {
            house.curCapacity -= 1;
            addPeopleToWildArea();
        }
    }
    
    function buyAsset(bool discount) public onlyLife payable {
        
        if(costActionPower(1)) {
            if(discount ) {
            
                setWoodenOffset(10, true);
                setWaterOffset(5, true);
                setVegetableOffset(5, true);
            } else  {
                Gate storage gate = gateMap[msg.sender];
                gate.monsterVitality -= 1;
            }
        }
    }
  
    function reStart() public {
        
        address _addr = msg.sender;
        uint balance = tokenBalance[_addr];
        if (balance == 2) {
            reset();
            tokenBalance[_addr] = 1;
        }
    }
    
    function reset() private {
        
        Vegetable storage vege = vegetableMap[msg.sender]; // = Vegetable(1,1, false, 10,10, 1, 3, 1)
        vege.grade = 1;
        vege.curCapacity = 5;
        Gate storage gate = gateMap[msg.sender]; // = Gate(0,0, 100, 100, 1, 3)
        gate.people = 0;
        gate.monsterVitality = 1;
        gate.curVitality = 10;
        gate.grade = 1;
        Facilities storage house = houseMap[msg.sender];// = Facilities(1, 1, 1, 5);
        house.curCapacity = 1;
        house.grade = 1;
        Facilities storage warehouse = warehouseMap[msg.sender]; //= Facilities(20, 20, 1, 5);
        warehouse.curCapacity = 10;
        warehouse.grade = 1;
        Facilities storage woodenbucket = woodenbucketMap[msg.sender];// = Facilities(10, 10, 1, 5);
        woodenbucket.curCapacity = 5;
        woodenbucket.grade = 1;
        Castle storage castle = castleMap[msg.sender];// = Castle(0,30, 22000, 1, false, false, false, 0);
        castle.liveDay = 1;
        castle.rainProbability = 10;
        castle.actionPower = 1;
        castle.diePeople = 0;
    }
    
    function newDay(uint256 randNonce) public onlyLife {
        
       clearDayState();
       checkWildArea(randNonce);
       Castle storage castle = castleMap[msg.sender];
       bool result = gateNewDay(castle.liveDay);
       if(result) {
           vegetableNewDay();
           rainfall(randNonce);
           result = updateDailyCost();
       }
      
       if(result == false){
            
            tokenBalance[msg.sender] = 2;
            uint curMax = castle.liveDay;
            if(curMax > maxRecord[msg.sender]) {
                maxRecord[msg.sender] = curMax;
            } 
       } else {
            castle.liveDay += 1;
            castle.actionPower = castle.liveDay;
       }
    }
    
    function clearDayState() private {
        
        dayStateMap[msg.sender].survival = 0;
        dayStateMap[msg.sender].isRain = false;
        dayStateMap[msg.sender].diePeople = 0;
        dayStateMap[msg.sender].searchPeople = 0;
    }
    
    function vegetableNewDay() private  {
        
        Vegetable storage vege = vegetableMap[msg.sender];
        setVegetableOffset(vege.grade, true);
    }
    
    function gateNewDay(uint256 liveDay) private returns(bool) {
        
        Gate storage gate = gateMap[msg.sender];
        gate.monsterVitality -=  gate.people;
        gate.curVitality -= gate.monsterVitality;
        if(gate.curVitality > 0) {
         
            gate.monsterVitality += liveDay;   
            return true;
        }
        
        return false;
    }
    
    function rainfall(uint256 randNonce) private {
        
        uint random = getRandom(randNonce + randomNonce);
        Castle storage  castle = castleMap[msg.sender];
        castle.rainProbability += 5;
        if(random <= castle.rainProbability && random >= 0) {
            Facilities storage woodenbucket = woodenbucketMap[msg.sender];
            woodenbucket.curCapacity = getMaxWoodenbucket(woodenbucket);
            
            dayStateMap[msg.sender].isRain = true;
            castle.rainProbability = 10;
        }
    
        randNonce = random;
    }
    
    function updateDailyCost() private returns(bool) {
        
        Facilities storage  house = houseMap[msg.sender];
        Gate storage  gate = gateMap[msg.sender];
        uint people = house.curCapacity;
        people += gate.people;
  
        Vegetable storage  vege = vegetableMap[msg.sender];
        Facilities storage  woodenbucket = woodenbucketMap[msg.sender];
        uint min = 0;
        if(vege.curCapacity > woodenbucket.curCapacity) {
            
            min = woodenbucket.curCapacity;
        } else {
            min = vege.curCapacity;
        }
        
        if(min == 0) {
            return false;
        }
        if(min > people) {
            
            vege.curCapacity -= people;
            woodenbucket.curCapacity -= people;
        } else {
            
            uint die = people - min;
            if(house.curCapacity > die){
               house.curCapacity -= die;
            } else {
                die -= house.curCapacity;
                house.curCapacity = 0;
                gate.people -= die;
            }
            Castle storage  castle = castleMap[msg.sender];
            castle.diePeople += die;
            dayStateMap[msg.sender].diePeople += die;
        }
        return true;
    }
    
    function costActionPower(uint256 num) private returns(bool) {
        
        Castle storage castle = castleMap[msg.sender];
        if (castle.actionPower >= num) {
            castle.actionPower -= num;
            return true;
        }
        return false;
    }
    
    function isLife(address who) private view returns(bool) {
        
        uint balance = tokenBalance[who];
        if(balance == 1) {
            return true;
        }
        return false;
    }
    
    function getMaxHouse(Facilities storage house) private view returns (uint) {
        
        return house.grade;
    }
    
    function getMaxWarehouse(Facilities storage warehouse) private view returns(uint) {
        
        return 20 + (warehouse.grade -1) * 10;
    }
    
    function getMaxWoodenbucket(Facilities storage woodenbucket) private view returns(uint) {
        
        return 10 + (woodenbucket.grade  - 1) * 2;
    }
    
    function getMaxVegetable(Vegetable storage vege) private view returns(uint) {
        
        return 10 + (vege.grade - 1) * 5;
    }
    
    function getMaxGateVitality(Gate storage gate) private view returns(uint){
        
        return 10 + (gate.grade - 1) *3; 
    }
    
    // WildArea
    function checkWildArea(uint256 randNonce) private {
        
        uint num = peoples[msg.sender];
        if(num == 0) {
            return;
        }
        
        for(uint i = 0;i < num; ++i) {
            tickWildArea(randNonce);
        }
 
        if(peoples[msg.sender] > 0) {
        
           Facilities storage  house = houseMap[msg.sender];
           house.curCapacity += peoples[msg.sender];
           uint maxHouse = getMaxHouse(house);
           if(house.curCapacity > maxHouse) {
               house.curCapacity = maxHouse;
           }
        }
        clearExpatriate();
    }
    
    function tickWildArea(uint256 randNonce) private {
        
        //die
        if(isHappen(2) == false) {
            
            bool isLive = true;
            //surviva
            if(isHappen(20)) {
                isLive = encounterSurvivor(randNonce);
            }
            
            if(!isLive) {
                diePeople();
                return;
            }
     
            //wooden
            if(isHappen(30)) {
                
                uint woodenR = getRandom(randNonce);
                randNonce += woodenR;
                uint vlue = woodenR / 10;
               
                setWoodenOffset(vlue, true);
            }
            
            //water
            if(isHappen(10)) {
                
                uint waterR = getRangeRandom(randNonce, 3, 5);
                randNonce += waterR;
                setWaterOffset(waterR, true);
            }
            
            //vagetable
            if(isHappen(20)) {
                
                uint vageR = getRangeRandom(randNonce, 3, 5);
                setVegetableOffset(vageR, true);
            }
        }  else {
          diePeople();
        }
    }
    
    function diePeople() private  {
        
        peoples[msg.sender] -= 1;
        Castle storage  castle = castleMap[msg.sender];
        dayStateMap[msg.sender].diePeople += 1;
        castle.diePeople += 1;
    }
    
    function encounterSurvivor(uint256 randNonce) private returns(bool) {
        
        if(isHappen(60)) {
            
            if(isHappen(30)) {
               addPeopleToWildArea();
               dayStateMap[msg.sender].survival += 1;
            }
            return true; 
        } else {
           if (isHappen(10)) {
            
                return false;
            }
            //vegetable
            if(isHappen(30)) {
        
                uint vege = getRangeRandom(randNonce, 1, 10);
                randNonce += vege;
                setVegetableOffset(vege, true);
            }
            //water
            if(isHappen(30)) {
            
                uint water = getRangeRandom(randNonce, 1, 10);
                randNonce += water;
                setWaterOffset(water, true);
            }
            //wooden
            if(isHappen(30)) {
            
                uint wooden = getRangeRandom(randNonce, 2 , 5);
                setWoodenOffset(wooden, true);
            }
            return true;
        }
    }
    
    function addPeopleToWildArea() private {
        
        address _addr = msg.sender;
        peoples[_addr] += 1;
    }
    
    function setWoodenOffset(uint num , bool isPlus) private {
        
        Facilities storage  warehouse = warehouseMap[msg.sender];
        if(isPlus) {
            warehouse.curCapacity += num;
            uint maxCapacity = getMaxWarehouse(warehouse);
            if(warehouse.curCapacity > maxCapacity) {
                warehouse.curCapacity = maxCapacity;
            }
        } else {
            warehouse.curCapacity -= num;
        }
    }
    
    function setWaterOffset(uint num , bool isPlus) private {
        
        Facilities storage  woodenbucket = woodenbucketMap[msg.sender];
        if(isPlus){
            woodenbucket.curCapacity += num;
            uint maxCapacity = getMaxWoodenbucket(woodenbucket);
            if(woodenbucket.curCapacity > maxCapacity) {
                woodenbucket.curCapacity = maxCapacity;
            }
        } else {
            woodenbucket.curCapacity -= num;
        }
    }
        
    function setVegetableOffset(uint num , bool isPlus) private {
        
        Vegetable storage  vege = vegetableMap[msg.sender];
        if(isPlus){
            vege.curCapacity += num;
            uint maxCapacity = getMaxVegetable(vege);
            if(vege.curCapacity > maxCapacity) {
                vege.curCapacity = maxCapacity;
            }
        } else {
            vege.curCapacity -= num;
        }
    }
    
    function getRangeRandom(uint256 randNonce, uint256 min, uint256 max) private view returns(uint256) {
          
        uint random = getRandom(randNonce);
        return  random % (100 / (max - min)) + min;
    }
    
    function clearExpatriate() private {
        
        peoples[msg.sender] = 0;
        delete peoples[msg.sender];
    }
        
    function isHappen(uint256 probability) private returns(bool) {
        
        uint random = getRandom(randomNonce++);
        if(probability >= random) {
            return true;
        }
        return false;
    }
    
    function getRandom(uint256 randNonce) private view returns(uint) {
        
        return uint(keccak256(now, msg.sender, randNonce)) % 100;
    }
}