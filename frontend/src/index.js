import React from 'react';
import ReactDOM from 'react-dom';
import { BrowserRouter, Route, Routes } from "react-router-dom";

import LandingPage from "./components/LandingPage"
import ProjectDetail from "./components/ProjectDetail"
import Navbar from "./components/Navbar"
import ProposalDetail from './components/proposals/ProposalDetail';

ReactDOM.render(
  <BrowserRouter>
    <Navbar/>
    <Routes>
      <Route path = "/" element={<LandingPage />} />
      <Route path = "/project/:id" element={<ProjectDetail />} />
      <Route path = "/project/:projectId/proposal/:proposalId" element={<ProposalDetail />} />
    </Routes>
  </BrowserRouter>,
  document.getElementById('root')
);