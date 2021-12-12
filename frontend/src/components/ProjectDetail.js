import React, {useState} from 'react';
import { useParams } from "react-router-dom";
import ProposalList from './proposals/ProposalList';
import data from "../data.json";
import ProposalForm from './proposals/ProposalForm';
import { Typography } from '@mui/material'; 

const ProjectDetail = () => {

   const [ toDoList, setToDoList ] = useState(data);
   const { id } = useParams();

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