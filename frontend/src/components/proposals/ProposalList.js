import React, {useState, useRef} from 'react';
import { useNavigate } from "react-router-dom";
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CardMedia from '@mui/material/CardMedia';
import Typography from '@mui/material/Typography';
import { Button, CardActionArea, CardActions } from '@mui/material';
import dao from '../../dao';
import web3 from '../../web3';

const ProposalList = ({toDoList}) => {

let minABI = [
  // transfer
  {
    "constant": false,
    "inputs": [
      {
        "name": "_to",
        "type": "address"
      },
      {
        "name": "_value",
        "type": "uint256"
      }
    ],
    "name": "transfer",
    "outputs": [
      {
        "name": "",
        "type": "bool"
      }
    ],
    "type": "function"
  }
];

    const navigate = useNavigate();

    const [voteAmount, setVoteAmount] = useState(0);
    const [message, setMessage] = useState("");

    const routeChange = (id) =>{ 
      let path = `proposal/` + id ; 
      navigate(path);
    }

    const handleClick = async (e) => {

        const accounts = await web3.eth.getAccounts();
        setMessage('Waiting on transaction success...');

        const tokenAddress = await dao.methods.getRaiseDaoTokenAddress.call()[0]

        // // Get ERC20 Token contract instance
        let contract = await new web3.eth.Contract(minABI, tokenAddress);
        // // calculate ERC20 token amount

        // // call transfer function
        // contract.transfer(toAddress, value, (error, txHash) => {
        //   // it returns tx hash because sending tx
        //   console.log(txHash);
        // });

        //contract.methods.transfer(to, 1000).encodeABI()

        await dao.methods.voteForProposal(0).send({
          from: accounts[0],
          value: contract.methods.transfer("0x08BE0e1Fe46657B8B6F1A4Ec5fab3e496e4160e8", 1).encodeABI(),
        });
        setMessage('You have been entered!');

        console.log(accounts)
    
    }

   return (
       <div>
           {toDoList.map(todo => {
               return (
                <Card sx={{ maxWidth: 800 }}>
                <CardActionArea>
                  {/* <CardMedia
                    component="img"
                    height="140"
                    image="/home/muskan/buildIt/my-app/public/logo192.png"
                    alt="green iguana"
                  /> */}
                 <CardContent>
                  <Typography gutterBottom variant="h5" component="div">
                  title: {todo[0]}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                  idea: {todo[1]}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                  ipfs link: {todo[2]}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                  /r/: {todo[3]}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                  creator: {todo[4]}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                  current support: {todo[5]}
                  </Typography>
                  </CardContent>
                </CardActionArea>
                <CardActions>
                  <Button size="small" color="primary" onClick={() => routeChange(todo.id)}>
                    Open
                  </Button>
                  <Button size="small" color="primary" onClick={() => handleClick()} >
                    Vote
                  </Button>
                </CardActions>
              </Card>
               )
           })}
        
       </div>
   );
};
 
export default ProposalList