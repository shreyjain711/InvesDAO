import React, { useState } from 'react';
import dao from '../../dao';
import web3 from '../../web3';

const ProposalForm = ({ addTask }) => {

    const [ userInput, setUserInput ] = useState('');
    const [message, setMessage] = useState('');
    const [value, setValue] = useState('');

    const handleChange = (e) => {
        setUserInput(e.currentTarget.value)
    }

    const handleSubmit = async (e) => {
        e.preventDefault();
        const accounts = await web3.eth.getAccounts();
        setMessage('Waiting on transaction success...');
        await dao.methods.enter().send({
          from: accounts[0],
          value: web3.utils.toWei(value, 'ether'),
        });
        setMessage('You have been entered!');

        console.log(accounts)
        
        addTask(userInput);
        setUserInput("");
    }
    return (
        <form onSubmit={handleSubmit}>
            <input value={userInput} type="text" onChange={handleChange} placeholder="Enter task..."/>
            <input
            style={{ marginLeft: '1vw' }}
            value={value}
            onChange={(e) => setValue(e.target.value)}
           />
            <button>Submit</button>
            <h1>{message}</h1>
        </form>
    );
};

export default ProposalForm;