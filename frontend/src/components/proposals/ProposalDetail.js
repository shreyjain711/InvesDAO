import React, {useState} from 'react';
import { useParams } from "react-router-dom";
import data from "../../data.json";

const ProposalDetail = () => {

   const [ toDoList, setToDoList ] = useState(data);
   const { proposalId } = useParams();

   return (
       <div>
           <h1>Proposal {proposalId}</h1>
           <p>About the proposal</p>
       </div>
   );
};
 
export default ProposalDetail;