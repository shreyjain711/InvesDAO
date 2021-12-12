import React, { useState } from 'react';
import dao from '../../dao';
import web3 from '../../web3';
import { TextField } from '@mui/material';
import { Grid } from '@mui/material';
import { Typography } from '@mui/material';
import { Button } from 'semantic-ui-react';

const ProposalForm = ({ addTask }) => {

    const [ userInput, setUserInput ] = useState('');
    const [message, setMessage] = useState('');
    const [title, setTitle] = useState('');
    const [idea, setIdea] = useState('');
    const [ipfs, setIpfs] = useState('');
    const [social, setSocial] = useState('');

    const handleSubmit = async (e) => {
        e.preventDefault();
        const accounts = await web3.eth.getAccounts();
        setMessage('Waiting on transaction success...');
        console.log(title, idea, ipfs, social);
        await dao.methods.createProposal(title, idea, ipfs, "DRDAO_P1", "DRDAOP1", social, 49, 49).send({
          from: accounts[0],
        });
        const output = await dao.methods.getProposalDetails(0).call();
        console.log(output);
        setMessage('You have been entered!');

        console.log(accounts)
        
        addTask(userInput);
        setUserInput("");
    }
    return (

        <div>

        <Typography variant="h3" align="center">Create New Proposal</Typography>

        <form onSubmit={handleSubmit}>
          <Grid container alignItems="center" justify="center" direction="column" spacing={1}>
            <TextField
            style={{ marginLeft: '1vw' }}
            value={title}
            onChange={(e) => setTitle(e.target.value)}
           />
           <TextField
            style={{ marginLeft: '1vw' }}
            value={idea}
            onChange={(e) => setIdea(e.target.value)}
           />
           <TextField
            style={{ marginLeft: '1vw' }}
            value={ipfs}
            onChange={(e) => setIpfs(e.target.value)}
           />
           <TextField
            style={{ marginLeft: '1vw' }}
            value={social}
            onChange={(e) => setSocial(e.target.value)}
           />
            <Button variant="outlined" >Upload Documents on IPFS</Button>
            <Button variant="outlined" >Submit</Button>
            <h1>{message}</h1>
            </Grid>
        </form>
        </div>
    );
};

export default ProposalForm