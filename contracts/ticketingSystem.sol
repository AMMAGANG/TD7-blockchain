pragma solidity >=0.4.22<0.6.0;


contract ticketingSystem {
    uint32 NextArtiste=1; 
    uint32 NextVenue=1; 
    uint32 NextConcert=1; 
    uint32 NextTicket=1; 
        struct Artist
        {
            address owner; 
            bytes32 name; 
            uint artistCategory;
        }
        mapping(uint => Artist) public artistsRegister; 

        function createArtist(bytes32 Name, uint Cate) public returns(bool){
            artistsRegister[NextArtiste].name=Name;
            artistsRegister[NextArtiste].artistCategory=Cate;
            artistsRegister[NextArtiste].owner=msg.sender;  
            NextArtiste = NextArtiste +1; 
            return true ; 
        }

        function modifyArtist(uint IDArtiste, bytes32 Name, uint newCate, address NewOwner) public returns(bool){
            require(artistsRegister[IDArtiste].owner == msg.sender);
            artistsRegister[IDArtiste].name=Name; 
            artistsRegister[IDArtiste].artistCategory=newCate; 
            artistsRegister[IDArtiste].owner=NewOwner; 
            return true;
        }

        struct Venue{

            uint capacity; 
            bytes32 name; 
            uint standardComission; 
            address payable owner; 
        }
        mapping (uint =>Venue) public venuesRegister; 

        function createVenue(bytes32 _name, uint _capacity, uint _standardComission)public 
        {
            venuesRegister[NextVenue].name=_name; 
            venuesRegister[NextVenue].capacity=_capacity; 
            venuesRegister[NextVenue].standardComission=_standardComission; 
            venuesRegister[NextVenue].owner = msg.sender; 
            NextVenue ++; 
        }

        function modifyVenue(uint _IdVenue, bytes32 _name, uint _capacity, uint _standardComission, address payable _owner) public
        {
        
           require(venuesRegister[_IdVenue].owner==msg.sender); 
           venuesRegister[_IdVenue].name=_name; 
           venuesRegister[_IdVenue].capacity=_capacity; 
           venuesRegister[_IdVenue].standardComission=_standardComission; 
           venuesRegister[_IdVenue].owner=_owner; 
        }

        struct Concert{

            uint artistId; 
            uint venueId; 
            uint concertDate; 
            uint nbrDeTickers; 
            uint concertPrice; 
            address payable owner; 
            bool validatedByArtist; 
            bool validatedByVenue; 
            uint TotSoldTickets; 
            uint TicketPrice; 
            uint TotMoneyCollect; 
        }

        mapping (uint => Concert) public concertsRegister; 

       
        function createConcert(uint _artistId, uint _venueId, uint _concertDate, uint _concertPrice)
        public
        returns (uint concertNumber)
        { 
        require(_concertDate >= now);
        require(artistsRegister[_artistId].owner != address(0));
        require(venuesRegister[_venueId].owner != address(0));
        concertsRegister[NextConcert].TotSoldTickets=0;
        concertsRegister[NextConcert].TotMoneyCollect=0;
        concertsRegister[NextConcert].concertDate = _concertDate;
        concertsRegister[NextConcert].artistId = _artistId;
        concertsRegister[NextConcert].venueId = _venueId;
        concertsRegister[NextConcert].concertPrice = _concertPrice;
        validateConcert(NextConcert);
        concertNumber = NextConcert;
        NextConcert +=1;
        }

        function validateConcert(uint _concertId)
        public
        {
        require(concertsRegister[_concertId].concertDate >= now);

        if (venuesRegister[concertsRegister[_concertId].venueId].owner == msg.sender)
        {
        concertsRegister[_concertId].validatedByVenue = true;
        }
        if (artistsRegister[concertsRegister[_concertId].artistId].owner == msg.sender)
        {
        concertsRegister[_concertId].validatedByArtist = true;
        }
        }

        struct Ticket {

        address owner;
        uint concertDate;
        uint artistId;			
        uint venueId;
        bool isAvailable;	
        bool isAvailableForSale;  
        uint amountPaid;   
        uint concertId; 
        }

        mapping (uint => Ticket) public ticketsRegister; 

       function emitTicket(uint _concertId, address payable _ticketOwner) public returns (uint ticketId) {
        require(artistsRegister[concertsRegister[_concertId].artistId].owner == msg.sender);
        ticketsRegister[_concertId].owner = _ticketOwner;
        ticketsRegister[_concertId].isAvailable = true;
        concertsRegister[_concertId].TotSoldTickets=concertsRegister[_concertId].TotSoldTickets+1;
        ticketId=NextTicket;
        NextTicket+=1;
        }

        function useTicket(uint _ticketId) public
        {
        require(msg.sender==ticketsRegister[_ticketId].owner);
        require(concertsRegister[ticketsRegister[_ticketId].concertId].concertDate>now);
        require(concertsRegister[ticketsRegister[_ticketId].concertId].concertDate<now+24*60*60);
        require(concertsRegister[ticketsRegister[_ticketId].concertId].validatedByArtist==true);
        require(concertsRegister[ticketsRegister[_ticketId].concertId].validatedByVenue==true);
        ticketsRegister[_ticketId].isAvailable=false;
        ticketsRegister[_ticketId].owner=address(0);  	
        }

        function buyTicket(uint _concertId)  payable public
        {

        require (msg.value==concertsRegister[_concertId].concertPrice);
        concertsRegister[_concertId].TotSoldTickets;
        concertsRegister[_concertId].TotMoneyCollect+=msg.value;
        ticketsRegister[NextTicket].owner=msg.sender;
        ticketsRegister[NextTicket].amountPaid=msg.value;
        ticketsRegister[NextTicket].concertId=_concertId;
        ticketsRegister[NextTicket].isAvailable=true;
        ticketsRegister[NextTicket].isAvailableForSale=false;
        NextTicket= NextTicket+1;
        }

        function transferTicket(uint _ticketId, address payable _newOwner) public
        {
        require(msg.sender==ticketsRegister[_ticketId].owner);
        ticketsRegister[_ticketId].owner=_newOwner;
        }


}