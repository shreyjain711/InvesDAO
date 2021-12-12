import React, {useState, useEffect} from 'react';
import { useParams } from "react-router-dom";
import ProposalList from './proposals/ProposalList';
import data from "../data.json";
import ProposalForm from './proposals/ProposalForm';
import { Typography } from '@mui/material'; 
import dao from '../dao'

const ProjectDetail = () => {

   const [ toDoList, setToDoList ] = useState([]);
   const { id } = useParams();

   useEffect(async () => {
    var numOfProposals = await dao.methods.getNumOfProposals().call();
    numOfProposals = numOfProposals[0];
    const proposalList = [];
    for(let i = 0; i < numOfProposals; i++) {
        const res = await dao.methods.getProposalDetails(i).call();
        proposalList.push(res);
    }

    setToDoList(proposalList)

    console.log(proposalList);
    }, []);

   const addTask = (userInput ) => {

    let copy = [...toDoList];
    copy = [...copy, { id: toDoList.length + 1, task: userInput, complete: false }];
    setToDoList(copy);
}

   return (
       <div>
           <Typography variant="h3" align="center">Project {id} Details </Typography>
           <ProposalList toDoList={toDoList}></ProposalList>
           <ProposalForm addTask={addTask}
          />
       </div>
   );
};
 
export default ProjectDetail;