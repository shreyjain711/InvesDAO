import React, { useState } from "react";
import data from "../data.json";
import ProjectList from "./ProjectList";
import dao from '../dao';
import { Typography } from "@mui/material";

function LandingPage() {

  const [ toDoList, setToDoList ] = useState(data);

  return (
      <div>
        <Typography variant="h3" align="center">Project Listing</Typography>
        <ProjectList toDoList={toDoList} />
      </div>
    )
}
export default LandingPage